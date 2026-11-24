-- 08_meeting_guard.sql
-- Stops the same meeting from being saved twice at the same time.

create unique index one_meeting_per_title_and_time
on meetings (lower(title), scheduled_at);

grant all on meetings to service_role;
grant all on meeting_attendees to service_role;
