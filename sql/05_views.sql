-- 05_views.sql
-- Pre-joined views the agent reads. security_invoker = true keeps row level security in force.

create view employee_directory
with (security_invoker = true) as
select
  e.id,
  e.full_name,
  e.email,
  e.role_title,
  d.name as department,
  m.full_name as manager,
  e.status,
  e.weekly_capacity_hours,
  e.hire_date
from employees e
join departments d on d.id = e.department_id
left join employees m on m.id = e.manager_id;

create view project_overview
with (security_invoker = true) as
select
  p.id,
  p.name,
  p.status,
  p.priority,
  p.start_date,
  p.deadline,
  p.deadline - current_date as days_until_deadline,
  p.budget,
  p.spent,
  round(p.spent / nullif(p.budget, 0) * 100, 1) as budget_used_percent,
  o.full_name as owner,
  c.company_name as customer,
  c.status as customer_status,
  count(t.id) as tasks_total,
  count(t.id) filter (where t.status = 'done') as tasks_done,
  count(t.id) filter (where t.status <> 'done' and t.due_date < current_date) as tasks_overdue,
  count(t.id) filter (where t.status = 'blocked') as tasks_blocked
from projects p
left join employees o on o.id = p.owner_id
left join customers c on c.id = p.customer_id
left join tasks t on t.project_id = p.id
group by p.id, o.full_name, c.company_name, c.status;

create view task_overview
with (security_invoker = true) as
select
  t.id,
  p.name as project,
  t.title,
  t.status,
  t.priority,
  e.full_name as assignee,
  e.status as assignee_status,
  t.due_date,
  (t.status <> 'done' and t.due_date < current_date) as is_overdue,
  case when t.status <> 'done' and t.due_date < current_date
       then current_date - t.due_date end as days_overdue,
  t.estimated_hours,
  (select string_agg(d.title, '; ')
     from task_dependencies td
     join tasks d on d.id = td.depends_on_task_id
    where td.task_id = t.id) as depends_on
from tasks t
join projects p on p.id = t.project_id
left join employees e on e.id = t.assignee_id;

-- Slimmer task view (fewer columns, fewer tokens)
create view task_brief
with (security_invoker = true) as
select
  id, project, title, status, priority,
  assignee, assignee_status, due_date, is_overdue, days_overdue
from task_overview;

create view customer_directory
with (security_invoker = true) as
select
  c.id,
  c.company_name,
  c.industry,
  c.contact_name,
  c.contact_email,
  c.account_tier,
  c.status,
  c.annual_contract_value,
  m.full_name as account_manager,
  (select string_agg(p.name, '; ')
     from projects p
    where p.customer_id = c.id) as projects
from customers c
left join employees m on m.id = c.account_manager_id;

create view employee_schedule
with (security_invoker = true) as
select
  e.id as employee_id,
  e.full_name,
  e.status as employee_status,
  m.id as meeting_id,
  m.title,
  m.scheduled_at,
  m.scheduled_at + m.duration_minutes * interval '1 minute' as ends_at,
  m.duration_minutes,
  m.scheduled_at >= now() as is_upcoming
from meeting_attendees ma
join employees e on e.id = ma.employee_id
join meetings m on m.id = ma.meeting_id;

grant select on employee_directory to service_role;
grant select on project_overview to service_role;
grant select on task_overview to service_role;
grant select on task_brief to service_role;
grant select on customer_directory to service_role;
grant select on employee_schedule to service_role;

notify pgrst, 'reload schema';
