-- 06_task_triggers.sql
-- Database-level rules for tasks. Run AFTER seed data (03): some seeded tasks are assigned
-- to an employee who is on leave, which the first trigger would reject.

-- 1. Never assign a task to someone who is not active (only checked when the assignee is set or changed)
create function check_assignee_active() returns trigger as $$
begin
  if new.assignee_id is not null
     and (tg_op = 'INSERT' or new.assignee_id is distinct from old.assignee_id) then
    if (select status from employees where id = new.assignee_id) <> 'active' then
      raise exception 'Cannot assign task to an employee who is not active';
    end if;
  end if;
  return new;
end;
$$ language plpgsql;

create trigger tasks_assignee_check
before insert or update on tasks
for each row execute function check_assignee_active();

-- 2. Keep completed_at in sync with status
create function sync_completed_at() returns trigger as $$
begin
  if new.status = 'done' and (tg_op = 'INSERT' or old.status <> 'done') then
    new.completed_at := now();
  elsif new.status <> 'done' then
    new.completed_at := null;
  end if;
  return new;
end;
$$ language plpgsql;

create trigger tasks_completed_sync
before insert or update on tasks
for each row execute function sync_completed_at();
