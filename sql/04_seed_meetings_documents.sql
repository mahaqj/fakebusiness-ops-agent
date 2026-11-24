-- 04_seed_meetings_documents.sql
-- Past meetings (with notes), upcoming meetings, attendees and internal documents.

insert into meetings (title, project_id, organizer_id, scheduled_at, duration_minutes, notes)
select v.title, p.id, e.id, v.at::timestamptz, v.mins, v.notes
from (values
  ('Brightwave Weekly Status', 'Brightwave Integration Portal', 'sofia.martinez@fakebusiness.example', '2026-11-12 15:00:00+00', 45,
   $$Dashboard UI is behind schedule. Aisha starts leave next week and no replacement is assigned yet. Production infrastructure is waiting on Brightwave to send their network allowlist. Integration testing cannot start until both are done. Carla Mendes (Brightwave) voiced concern about the Dec 4 deadline. Actions: Sofia to find backup frontend capacity; Hannah to chase the allowlist from Brightwave.$$),
  ('SOC 2 Steering Committee', 'SOC 2 Compliance Preparation', 'zara.ahmed@fakebusiness.example', '2026-11-10 14:00:00+00', 60,
   $$MFA rollout complete. Vendor risk assessments are slower than planned because three vendors have not replied. Security awareness training needs a company-wide date. Pen test vendor shortlist due before Dec 4. Actions: Zara to chase vendors; Hannah to schedule training.$$),
  ('Mobile App v2 Sprint Review', 'Mobile App v2 Launch', 'lucas.silva@fakebusiness.example', '2026-11-17 10:00:00+00', 60,
   $$Offline sync module is about 60 percent done and on track for Nov 25. Launch announcement draft is late and still has no owner time allocated. Push notification work can start once the sync module is merged. Beta tester recruitment to begin early December.$$),
  ('Weekly Operations Review', null, 'zara.ahmed@fakebusiness.example', '2026-11-16 09:00:00+00', 30,
   $$Brightwave is the top risk: the account is at risk and the portal is behind. Aisha is on leave, which affects Brightwave and Mobile App v2. SOC 2 is at risk of slipping if vendor assessments are not finished. Priya asked for a delay-risk summary before the next review.$$),
  ('Quantix Requirements Workshop', 'Quantix Analytics Dashboard', 'lucas.silva@fakebusiness.example', '2026-11-24 13:00:00+00', 90, null),
  ('Brightwave Escalation Call', 'Brightwave Integration Portal', 'olivia.brown@fakebusiness.example', '2026-11-23 14:00:00+00', 30, null)
) as v(title, project, organizer, at, mins, notes)
left join projects p on p.name = v.project
join employees e on e.email = v.organizer;

insert into meeting_attendees (meeting_id, employee_id)
select m.id, e.id
from (values
  ('Brightwave Weekly Status', 'sofia.martinez@fakebusiness.example'),
  ('Brightwave Weekly Status', 'liam.chen@fakebusiness.example'),
  ('Brightwave Weekly Status', 'aisha.khan@fakebusiness.example'),
  ('Brightwave Weekly Status', 'noah.williams@fakebusiness.example'),
  ('Brightwave Weekly Status', 'hannah.weber@fakebusiness.example'),
  ('SOC 2 Steering Committee', 'daniel.okafor@fakebusiness.example'),
  ('SOC 2 Steering Committee', 'zara.ahmed@fakebusiness.example'),
  ('SOC 2 Steering Committee', 'noah.williams@fakebusiness.example'),
  ('SOC 2 Steering Committee', 'hannah.weber@fakebusiness.example'),
  ('Mobile App v2 Sprint Review', 'lucas.silva@fakebusiness.example'),
  ('Mobile App v2 Sprint Review', 'liam.chen@fakebusiness.example'),
  ('Mobile App v2 Sprint Review', 'noah.williams@fakebusiness.example'),
  ('Mobile App v2 Sprint Review', 'ethan.park@fakebusiness.example'),
  ('Mobile App v2 Sprint Review', 'emma.johansson@fakebusiness.example'),
  ('Weekly Operations Review', 'priya.raman@fakebusiness.example'),
  ('Weekly Operations Review', 'daniel.okafor@fakebusiness.example'),
  ('Weekly Operations Review', 'emma.johansson@fakebusiness.example'),
  ('Weekly Operations Review', 'olivia.brown@fakebusiness.example'),
  ('Weekly Operations Review', 'hannah.weber@fakebusiness.example'),
  ('Weekly Operations Review', 'zara.ahmed@fakebusiness.example'),
  ('Quantix Requirements Workshop', 'lucas.silva@fakebusiness.example'),
  ('Quantix Requirements Workshop', 'liam.chen@fakebusiness.example'),
  ('Quantix Requirements Workshop', 'hannah.weber@fakebusiness.example'),
  ('Brightwave Escalation Call', 'olivia.brown@fakebusiness.example'),
  ('Brightwave Escalation Call', 'sofia.martinez@fakebusiness.example'),
  ('Brightwave Escalation Call', 'hannah.weber@fakebusiness.example'),
  ('Brightwave Escalation Call', 'daniel.okafor@fakebusiness.example')
) as v(meeting, email)
join meetings m on m.title = v.meeting
join employees e on e.email = v.email;

insert into documents (title, doc_type, project_id, content)
select v.title, v.doc_type, p.id, v.content
from (values
  ('Remote Work and Time Off Policy', 'policy', null,
   $$All employees may work remotely up to 3 days per week unless their role requires on-site presence. Annual leave must be requested at least 2 weeks in advance for absences over 3 days. Employees on leave must not be assigned new tasks, and their open tasks must be reassigned by their manager before the leave starts. Meetings should not be scheduled outside 9:00-17:00 in the attendee's local time.$$),
  ('Task and Project Management Procedure', 'procedure', null,
   $$Every task must belong to a project, have one assignee, a priority and a due date. A task is overdue when its due date has passed and its status is not done. Overdue critical or high priority tasks must be reported to the project owner within one working day. Tasks may only be reassigned to employees with status active and enough weekly capacity. Do not create a task if one with the same title already exists in the project. Project status reports must list: progress, overdue tasks, blockers, budget spent versus budget, and recommended actions.$$),
  ('External Communications and Approval Policy', 'policy', null,
   $$Any email sent to a customer or any person outside FakeBusiness must be approved by a human before sending. Internal reminders about overdue tasks may be drafted automatically but must be reviewed before sending. Calendar invites that include external guests need approval. Changes to project deadlines, budgets or priorities need approval from the project owner. Automated systems must never promise delivery dates, discounts or contract terms to customers.$$),
  ('Brightwave Integration Portal: Project Brief', 'project_brief', 'Brightwave Integration Portal',
   $$Goal: deliver a customer-facing portal for Brightwave Logistics with shipment tracking, alerts and SSO, going live by Dec 4, 2026. Brightwave is an enterprise customer ($240k annual contract) currently flagged at risk, and a successful launch is the main factor in their renewal. Scope: SSO, shipment tracking API, customer dashboard, production infrastructure, integration testing, user acceptance testing, documentation. Key risks: frontend capacity, dependency on Brightwave supplying network access details, tight testing window.$$),
  ('Mobile App v2: Project Brief', 'project_brief', 'Mobile App v2 Launch',
   $$Goal: release version 2 of the FakeBusiness mobile app by Jan 29, 2027 with offline mode, push notifications and a new onboarding experience. Success metrics: 20 percent increase in weekly active users within 3 months of launch, app store rating of 4.5 or higher. Launch plan needs: finalized features, beta program, launch announcement, pricing page update and app store submission. Key risks: offline sync complexity and limited design capacity.$$),
  ('FakeBusiness Platform Overview', 'product_doc', null,
   $$FakeBusiness is a B2B SaaS platform for logistics and operations teams. Core modules: shipment and asset tracking, workflow automation, analytics dashboards and a mobile app. Customers are offered Starter, Business and Enterprise tiers. Enterprise includes SSO, a dedicated account manager and priority support. The platform exposes a REST API and supports integrations with common customer systems.$$),
  ('Q4 Planning Offsite Notes', 'meeting_notes', null,
   $$Q4 priorities agreed: 1) ship the Brightwave portal on time, 2) achieve SOC 2 readiness by mid-December, 3) launch Mobile App v2 in January, 4) start the Quantix dashboard. Concern raised that Engineering capacity is stretched across three projects, with Liam Chen on all of them. Decision: protect Brightwave first when priorities conflict.$$)
) as v(title, doc_type, project, content)
left join projects p on p.name = v.project;
