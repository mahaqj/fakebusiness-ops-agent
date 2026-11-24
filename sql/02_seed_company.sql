-- 02_seed_company.sql
-- Fictional departments, employees and customers. All emails use the reserved .example domain.

insert into departments (name, description) values
  ('Engineering', 'Builds and maintains the FakeBusiness platform'),
  ('Product', 'Owns roadmap, requirements and launches'),
  ('Sales', 'New business and contract negotiation'),
  ('Customer Success', 'Onboarding, support and renewals'),
  ('Operations', 'Company management, finance and internal processes');

-- Employees (department and manager are looked up by name/email, so IDs are never guessed)
insert into employees (full_name, email, role_title, department_id, manager_id, hire_date, status, weekly_capacity_hours) values
  ('Priya Raman', 'priya.raman@fakebusiness.example', 'CEO',
    (select id from departments where name='Operations'), null, '2019-03-01', 'active', 40);

insert into employees (full_name, email, role_title, department_id, manager_id, hire_date, status, weekly_capacity_hours) values
  ('Daniel Okafor', 'daniel.okafor@fakebusiness.example', 'VP of Engineering',
    (select id from departments where name='Engineering'),
    (select id from employees where email='priya.raman@fakebusiness.example'), '2019-06-15', 'active', 40),
  ('Emma Johansson', 'emma.johansson@fakebusiness.example', 'Head of Product',
    (select id from departments where name='Product'),
    (select id from employees where email='priya.raman@fakebusiness.example'), '2020-01-10', 'active', 40),
  ('Olivia Brown', 'olivia.brown@fakebusiness.example', 'Sales Director',
    (select id from departments where name='Sales'),
    (select id from employees where email='priya.raman@fakebusiness.example'), '2020-04-20', 'active', 40),
  ('Hannah Weber', 'hannah.weber@fakebusiness.example', 'Head of Customer Success',
    (select id from departments where name='Customer Success'),
    (select id from employees where email='priya.raman@fakebusiness.example'), '2020-09-01', 'active', 40),
  ('Zara Ahmed', 'zara.ahmed@fakebusiness.example', 'Operations Manager',
    (select id from departments where name='Operations'),
    (select id from employees where email='priya.raman@fakebusiness.example'), '2021-02-08', 'active', 32);

insert into employees (full_name, email, role_title, department_id, manager_id, hire_date, status, weekly_capacity_hours) values
  ('Sofia Martinez', 'sofia.martinez@fakebusiness.example', 'Engineering Manager',
    (select id from departments where name='Engineering'),
    (select id from employees where email='daniel.okafor@fakebusiness.example'), '2020-08-03', 'active', 40),
  ('Lucas Silva', 'lucas.silva@fakebusiness.example', 'Product Manager',
    (select id from departments where name='Product'),
    (select id from employees where email='emma.johansson@fakebusiness.example'), '2021-05-17', 'active', 40),
  ('Mateo Rossi', 'mateo.rossi@fakebusiness.example', 'Account Executive',
    (select id from departments where name='Sales'),
    (select id from employees where email='olivia.brown@fakebusiness.example'), '2021-11-01', 'active', 40),
  ('Ethan Park', 'ethan.park@fakebusiness.example', 'Support Specialist',
    (select id from departments where name='Customer Success'),
    (select id from employees where email='hannah.weber@fakebusiness.example'), '2022-03-14', 'active', 40);

insert into employees (full_name, email, role_title, department_id, manager_id, hire_date, status, weekly_capacity_hours) values
  ('Liam Chen', 'liam.chen@fakebusiness.example', 'Senior Backend Engineer',
    (select id from departments where name='Engineering'),
    (select id from employees where email='sofia.martinez@fakebusiness.example'), '2021-01-25', 'active', 40),
  ('Aisha Khan', 'aisha.khan@fakebusiness.example', 'Frontend Engineer',
    (select id from departments where name='Engineering'),
    (select id from employees where email='sofia.martinez@fakebusiness.example'), '2022-07-11', 'on_leave', 40),
  ('Noah Williams', 'noah.williams@fakebusiness.example', 'DevOps Engineer',
    (select id from departments where name='Engineering'),
    (select id from employees where email='sofia.martinez@fakebusiness.example'), '2022-10-03', 'active', 40);

insert into customers (company_name, industry, contact_name, contact_email, account_tier, account_manager_id, annual_contract_value, status) values
  ('Brightwave Logistics', 'Logistics', 'Carla Mendes', 'carla.mendes@brightwave.example', 'enterprise',
    (select id from employees where email='olivia.brown@fakebusiness.example'), 240000, 'at_risk'),
  ('Harbor & Finch Retail', 'Retail', 'Tom Hartley', 'tom.hartley@harborfinch.example', 'business',
    (select id from employees where email='mateo.rossi@fakebusiness.example'), 78000, 'active'),
  ('Quantix Health', 'Healthcare', 'Dr. Meera Iyer', 'meera.iyer@quantix.example', 'enterprise',
    (select id from employees where email='hannah.weber@fakebusiness.example'), 180000, 'active'),
  ('Lumen Education', 'Education', 'Greg Palmer', 'greg.palmer@lumen.example', 'starter',
    (select id from employees where email='mateo.rossi@fakebusiness.example'), 12000, 'active');
