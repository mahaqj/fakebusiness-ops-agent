-- 03_seed_projects_tasks.sql
-- Projects, team membership, tasks and dependencies.
-- Several tasks are deliberately overdue relative to Nov 2026 so the agent has real work to find.
-- Run BEFORE 06_task_triggers.sql: some seeded tasks belong to Aisha Khan (on leave),
-- which the assignee trigger would otherwise reject.

insert into projects (name, description, status, priority, start_date, deadline, budget, spent, owner_id, customer_id) values
  ('Brightwave Integration Portal',
   'Customer-facing portal with shipment tracking and SSO for Brightwave Logistics',
   'active', 'critical', '2026-08-17', '2026-12-04', 180000, 151000,
   (select id from employees where email='sofia.martinez@fakebusiness.example'),
   (select id from customers where company_name='Brightwave Logistics')),
  ('Mobile App v2 Launch',
   'Major release of the FakeBusiness mobile app with offline mode and notifications',
   'active', 'high', '2026-09-01', '2027-01-29', 220000, 96000,
   (select id from employees where email='lucas.silva@fakebusiness.example'),
   null),
  ('SOC 2 Compliance Preparation',
   'Security policies, controls and audit readiness for SOC 2 certification',
   'active', 'high', '2026-09-14', '2026-12-18', 90000, 61000,
   (select id from employees where email='daniel.okafor@fakebusiness.example'),
   null),
  ('Quantix Analytics Dashboard',
   'Custom analytics dashboard for Quantix Health',
   'planning', 'medium', '2026-12-01', '2027-03-15', 130000, 8000,
   (select id from employees where email='lucas.silva@fakebusiness.example'),
   (select id from customers where company_name='Quantix Health')),
  ('Customer Onboarding Revamp',
   'Redesigned onboarding checklist and video series for new customers',
   'completed', 'medium', '2026-03-02', '2026-08-28', 60000, 57500,
   (select id from employees where email='hannah.weber@fakebusiness.example'),
   null);

insert into project_members (project_id, employee_id, role_on_project, allocation_percent)
select p.id, e.id, v.role_name, v.alloc
from (values
  ('Brightwave Integration Portal', 'sofia.martinez@fakebusiness.example', 'Project Lead', 30),
  ('Brightwave Integration Portal', 'liam.chen@fakebusiness.example', 'Tech Lead', 50),
  ('Brightwave Integration Portal', 'aisha.khan@fakebusiness.example', 'Frontend Engineer', 50),
  ('Brightwave Integration Portal', 'noah.williams@fakebusiness.example', 'DevOps Engineer', 40),
  ('Brightwave Integration Portal', 'hannah.weber@fakebusiness.example', 'Customer Liaison', 20),
  ('Brightwave Integration Portal', 'ethan.park@fakebusiness.example', 'Documentation and Support', 25),
  ('Mobile App v2 Launch', 'lucas.silva@fakebusiness.example', 'Product Owner', 60),
  ('Mobile App v2 Launch', 'liam.chen@fakebusiness.example', 'Backend Engineer', 30),
  ('Mobile App v2 Launch', 'aisha.khan@fakebusiness.example', 'Mobile Designer', 30),
  ('Mobile App v2 Launch', 'noah.williams@fakebusiness.example', 'DevOps Engineer', 30),
  ('Mobile App v2 Launch', 'ethan.park@fakebusiness.example', 'Beta Program Coordinator', 25),
  ('Mobile App v2 Launch', 'emma.johansson@fakebusiness.example', 'Launch Sponsor', 20),
  ('SOC 2 Compliance Preparation', 'daniel.okafor@fakebusiness.example', 'Executive Sponsor', 20),
  ('SOC 2 Compliance Preparation', 'zara.ahmed@fakebusiness.example', 'Compliance Lead', 60),
  ('SOC 2 Compliance Preparation', 'noah.williams@fakebusiness.example', 'Infrastructure Security', 30),
  ('SOC 2 Compliance Preparation', 'liam.chen@fakebusiness.example', 'Remediation Engineer', 10),
  ('SOC 2 Compliance Preparation', 'hannah.weber@fakebusiness.example', 'Training Coordinator', 10),
  ('Quantix Analytics Dashboard', 'lucas.silva@fakebusiness.example', 'Product Manager', 40),
  ('Quantix Analytics Dashboard', 'liam.chen@fakebusiness.example', 'Data Engineer', 10),
  ('Quantix Analytics Dashboard', 'aisha.khan@fakebusiness.example', 'Designer', 20),
  ('Customer Onboarding Revamp', 'hannah.weber@fakebusiness.example', 'Project Owner', 30),
  ('Customer Onboarding Revamp', 'ethan.park@fakebusiness.example', 'Content Producer', 40)
) as v(project, email, role_name, alloc)
join projects p on p.name = v.project
join employees e on e.email = v.email;

insert into tasks (project_id, title, description, status, priority, assignee_id, due_date, estimated_hours, completed_at)
select p.id, v.title, v.descr, v.status, v.priority, e.id, v.due::date, v.hours::numeric,
       case when v.status = 'done' then v.due::date::timestamptz end
from (values
  ('Brightwave Integration Portal', 'Design SSO authentication flow', 'Define SAML/OIDC login flow for Brightwave staff', 'done', 'high', 'liam.chen@fakebusiness.example', '2026-09-25', 24),
  ('Brightwave Integration Portal', 'Build shipment tracking API', 'REST API exposing live shipment status', 'done', 'high', 'liam.chen@fakebusiness.example', '2026-10-23', 60),
  ('Brightwave Integration Portal', 'Build customer dashboard UI', 'Frontend for tracking, alerts and reports', 'in_progress', 'high', 'aisha.khan@fakebusiness.example', '2026-11-06', 48),
  ('Brightwave Integration Portal', 'Set up production infrastructure', 'Production environment, monitoring and backups', 'in_progress', 'high', 'noah.williams@fakebusiness.example', '2026-11-13', 32),
  ('Brightwave Integration Portal', 'Integration testing with Brightwave systems', 'End-to-end tests against their staging systems', 'blocked', 'critical', 'sofia.martinez@fakebusiness.example', '2026-11-20', 40),
  ('Brightwave Integration Portal', 'Customer UAT and sign-off', 'Brightwave acceptance testing and formal approval', 'todo', 'critical', 'hannah.weber@fakebusiness.example', '2026-11-30', 24),
  ('Brightwave Integration Portal', 'Write portal user documentation', 'User guide and FAQ for Brightwave staff', 'todo', 'medium', 'ethan.park@fakebusiness.example', '2026-11-27', 16),
  ('Mobile App v2 Launch', 'Finalize v2 feature scope', 'Agree final feature list for the release', 'done', 'high', 'lucas.silva@fakebusiness.example', '2026-09-18', 16),
  ('Mobile App v2 Launch', 'Design new onboarding screens', 'First-run experience and tutorial screens', 'done', 'medium', 'aisha.khan@fakebusiness.example', '2026-10-16', 40),
  ('Mobile App v2 Launch', 'Build offline sync module', 'Local storage and conflict-free sync', 'in_progress', 'high', 'liam.chen@fakebusiness.example', '2026-11-25', 56),
  ('Mobile App v2 Launch', 'Push notification service', 'Backend service and device registration', 'todo', 'medium', 'noah.williams@fakebusiness.example', '2026-12-11', 30),
  ('Mobile App v2 Launch', 'Draft launch announcement and pricing page', 'Launch messaging, blog post and pricing copy', 'todo', 'high', 'emma.johansson@fakebusiness.example', '2026-11-16', 20),
  ('Mobile App v2 Launch', 'Beta test program', 'Recruit testers, collect and triage feedback', 'todo', 'medium', 'ethan.park@fakebusiness.example', '2027-01-08', 24),
  ('Mobile App v2 Launch', 'App store submission', 'Submit to both stores and handle review', 'todo', 'high', 'lucas.silva@fakebusiness.example', '2027-01-22', 12),
  ('SOC 2 Compliance Preparation', 'Draft information security policy', 'Company-wide security policy document', 'done', 'high', 'zara.ahmed@fakebusiness.example', '2026-10-02', 20),
  ('SOC 2 Compliance Preparation', 'Enable MFA for all internal systems', 'Roll out multi-factor authentication everywhere', 'done', 'high', 'noah.williams@fakebusiness.example', '2026-10-30', 24),
  ('SOC 2 Compliance Preparation', 'Complete vendor risk assessments', 'Assess every third-party vendor handling data', 'in_progress', 'medium', 'zara.ahmed@fakebusiness.example', '2026-11-12', 30),
  ('SOC 2 Compliance Preparation', 'Employee security awareness training', 'Company-wide training and completion tracking', 'todo', 'medium', 'hannah.weber@fakebusiness.example', '2026-11-18', 12),
  ('SOC 2 Compliance Preparation', 'Penetration test engagement', 'Hire testers and scope the engagement', 'todo', 'high', 'daniel.okafor@fakebusiness.example', '2026-12-04', 16),
  ('SOC 2 Compliance Preparation', 'Remediate pen test findings', 'Fix issues found by the penetration test', 'todo', 'high', 'liam.chen@fakebusiness.example', '2026-12-14', 50),
  ('Quantix Analytics Dashboard', 'Gather dashboard requirements from Quantix', 'Workshops with Quantix stakeholders', 'in_progress', 'high', 'lucas.silva@fakebusiness.example', '2026-11-24', 20),
  ('Quantix Analytics Dashboard', 'Define data model and metrics', 'Metrics list and data model for the dashboard', 'todo', 'medium', 'liam.chen@fakebusiness.example', '2026-12-08', 24),
  ('Quantix Analytics Dashboard', 'Dashboard wireframes', 'Low-fidelity layouts for review', 'todo', 'medium', 'aisha.khan@fakebusiness.example', '2026-12-15', 24),
  ('Customer Onboarding Revamp', 'Redesign onboarding checklist', 'New step-by-step checklist for customers', 'done', 'medium', 'hannah.weber@fakebusiness.example', '2026-06-30', 30),
  ('Customer Onboarding Revamp', 'Record onboarding video series', 'Five short walkthrough videos', 'done', 'medium', 'ethan.park@fakebusiness.example', '2026-08-14', 40)
) as v(project, title, descr, status, priority, assignee, due, hours)
join projects p on p.name = v.project
left join employees e on e.email = v.assignee;

-- Dependencies: "task" cannot start until "needs" is done
insert into task_dependencies (task_id, depends_on_task_id)
select t.id, d.id
from (values
  ('Brightwave Integration Portal', 'Build customer dashboard UI', 'Build shipment tracking API'),
  ('Brightwave Integration Portal', 'Integration testing with Brightwave systems', 'Build customer dashboard UI'),
  ('Brightwave Integration Portal', 'Integration testing with Brightwave systems', 'Set up production infrastructure'),
  ('Brightwave Integration Portal', 'Customer UAT and sign-off', 'Integration testing with Brightwave systems'),
  ('Mobile App v2 Launch', 'Beta test program', 'Build offline sync module'),
  ('Mobile App v2 Launch', 'App store submission', 'Beta test program'),
  ('SOC 2 Compliance Preparation', 'Remediate pen test findings', 'Penetration test engagement'),
  ('Quantix Analytics Dashboard', 'Define data model and metrics', 'Gather dashboard requirements from Quantix'),
  ('Quantix Analytics Dashboard', 'Dashboard wireframes', 'Gather dashboard requirements from Quantix')
) as v(project, task, needs)
join projects p on p.name = v.project
join tasks t on t.project_id = p.id and t.title = v.task
join tasks d on d.project_id = p.id and d.title = v.needs;
