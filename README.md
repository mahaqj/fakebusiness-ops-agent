# FakeBusiness Ops Agent

An AI operations assistant built in **n8n** for a fictional B2B software company, FakeBusiness. You give it a business goal in plain language ("Brightwave recovery: create a task, email the project owner, schedule a sync") and it looks up company data, plans the steps, runs them, and reports what actually happened.

It is not a chatbot over a database. It reads and writes real records, and every consequential action is gated, logged and checked at the database level.

> All company data is fictional (emails use the reserved `.example` domain). Gmail and Google Calendar are real integrations and were tested with a throwaway account and a test calendar.

## Architecture

```
n8n Chat Trigger
      |
      v
  AI Agent  <-- Google Gemini (chat model) + Simple Memory
      |
      +-- Read tools (sub-workflows) --> Supabase views/tables
      |     employees, projects, tasks, customers,
      |     schedule, documents, runs, actions
      |
      +-- Bookkeeping tools --> agent_runs, agent_actions,
      |     meetings, meeting_attendees
      |
      +-- Human review (Chat approval buttons)
            +-- send_email         (Gmail)
            +-- create_event       (Google Calendar)
            +-- create_task / update_task_status / reassign_task

Supabase PostgreSQL = single source of truth
  constraints + triggers enforce the rules, an audit log records every change
```

## Features

- **Multi-step planning with persistent state.** Plans are stored in `agent_runs` and `agent_actions`, not in chat memory. Each step moves through planned, completed, failed, denied or skipped, and the final report is built from the stored steps.
- **Human-in-the-loop approvals.** Emails, calendar events and task changes pause for an Approve or Disapprove click inside the chat. A denial is recorded and never retried.
- **Duplicate protection.** Unique constraints stop duplicate tasks, meetings and open runs. The agent also checks before writing.
- **Policy-aware.** The agent reads company policy documents and quotes them, and says so when no document covers a question.
- **Availability-aware scheduling.** It checks each attendee's meetings and status before proposing a time, and never assigns work to someone on leave.
- **Audit log.** Database triggers record every insert, update and delete on tasks, meetings, meeting attendees and agent steps, with the old and new row and the database role that made the change.
- **Failure alerts.** A separate error workflow posts failed workflow runs to Discord.

## Tech stack

n8n (Cloud), Supabase PostgreSQL, Google Gemini, Gmail, Google Calendar, Discord (error alerts).

## Data model

13 tables: `departments`, `employees`, `customers`, `projects`, `project_members`, `tasks`, `task_dependencies`, `meetings`, `meeting_attendees`, `documents`, `agent_runs`, `agent_actions`, `audit_log`.

6 views that pre-join data for the agent: `employee_directory`, `project_overview`, `task_overview`, `task_brief`, `customer_directory`, `employee_schedule`. They are created with `security_invoker = true` so row level security still applies.

## Database safeguards

| Safeguard | What it does |
|---|---|
| `unique (project_id, title)` on tasks | No duplicate task in a project |
| Unique index on meetings (title, start time) | No duplicate meeting records |
| Unique index on open runs by goal | No duplicate open runs with identical goals |
| `check` constraints on every status column | The agent cannot invent statuses |
| Trigger: active assignee only | Tasks cannot be assigned to someone on leave |
| Trigger: `completed_at` sync | Completion time always matches status |
| Audit triggers | Every change is recorded, including who made it |
| Row level security on all tables | Public keys cannot read or write |

## Setup

1. **Supabase.** Create a project, then run the SQL files in `sql/` in this order: schema, seed data, views, agent tables, triggers, audit log. Enable row level security and grant `service_role` access to each table. If n8n reports "permission denied", use the legacy `service_role` key in the credential.
2. **n8n.** Import the workflows from `workflows/`. Credentials are not included in the exports, so create these yourself: Supabase, Google Gemini, Gmail, Google Calendar, Discord webhook. After importing:
   - Import the `Tool: Get ...` sub-workflows first, then open each of the 8 read-tool nodes in the agent (`get_employees`, `get_projects`, `get_tasks`, `get_customers`, `get_schedule`, `get_runs`, `get_actions`, `get_documents`) and re-select its sub-workflow, because the workflow IDs differ in your instance.
   - Replace the placeholders `YOUR_SUPABASE_PROJECT_REF` (in each Supabase node) and `YOUR_TEST_CALENDAR_ID` (in `create_event`) with your own values.
3. **Chat Trigger.** Set **Response Mode** to **Using Response Nodes**, and keep the Chat node after the agent that sends `{{ $json.output }}`.
4. **Agent settings.** Set **Simple Memory** to a context window of 20 and **Max Iterations** to 25.
5. **Approvals.** Plug `send_email`, `create_event`, `create_task`, `update_task_status` and `reassign_task` into the Chat review node, not directly into the agent.
6. **Error alerts.** Publish the error workflow and select it under the agent workflow's settings.
7. **Test accounts.** Use a test Gmail account and a separate test calendar. Seeded addresses are fake, so point one employee at your test inbox to see an email arrive.

Paste the system message from `docs/system-message.md` into the AI Agent node.

## Example requests

- `Which tasks are overdue, and who owns them?`
- `Which tasks in the Mobile App v2 Launch project are blocked or waiting on something?`
- `Find a 30-minute slot on 2026-11-24 when Hannah Weber and Liam Chen are both free.`
- `What is our policy on sending emails to customers?`
- `Goal: Brightwave recovery. Create one high priority task ..., email Sofia Martinez about it, schedule a 30-minute sync. Plan the steps and log them, but do not execute anything yet.`

## Known limitations

- **Behavior rules in the prompt are not guaranteed.** Database constraints and the approval step are enforced. Rules such as "do not retry after an error" or "check before writing" depend on the model following instructions, and it occasionally does not. The database rejects the harmful cases.
- **Tool errors reach the agent as a generic message.** The detailed database error is visible in the n8n execution logs.
- **Approval channel.** Gmail as the review channel did not return tool results to the chat in my testing, so the n8n Chat channel is used instead.
- **Gemini history errors.** A small memory window can cut a tool call from its result and cause a "function response parts" error. A window of 20 avoided it.
- **Rate limits.** Free model tiers hit token limits quickly on long goals. The agent was tested on Gemini and briefly on Groq.
- **Not RAG.** Document retrieval is a plain table read, which is enough for a handful of documents.
- **Calendar and database are separate.** A created event is saved to the `meetings` table by a follow-up step, and nothing keeps the two in sync afterwards.
- **Audit log scope.** It records the database role (`service_role` for n8n, `postgres` for manual edits), not which tool or person.

## Repository layout

```
workflows/   n8n exports (agent, error alert, tool sub-workflows)
sql/         schema, seed data, views, triggers, audit log
docs/        system-message.md
```
