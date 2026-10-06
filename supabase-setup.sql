create table if not exists public.codevault_state (
    id integer primary key default 1 check (id = 1),
    payload jsonb not null default '{"items": [], "folders": []}'::jsonb,
    updated_at timestamptz not null default now()
);

alter table public.codevault_state enable row level security;
grant usage on schema public to anon;
grant select, insert, update on public.codevault_state to anon;

drop policy if exists "Anyone can read the shared CodeVault" on public.codevault_state;
create policy "Anyone can read the shared CodeVault"
    on public.codevault_state for select to anon
    using (id = 1);

drop policy if exists "Anyone can create the shared CodeVault" on public.codevault_state;
create policy "Anyone can create the shared CodeVault"
    on public.codevault_state for insert to anon
    with check (id = 1);

drop policy if exists "Anyone can update the shared CodeVault" on public.codevault_state;
create policy "Anyone can update the shared CodeVault"
    on public.codevault_state for update to anon
    using (id = 1)
    with check (id = 1);

create or replace function public.codevault_set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

drop trigger if exists codevault_set_updated_at on public.codevault_state;
create trigger codevault_set_updated_at
    before update on public.codevault_state
    for each row execute function public.codevault_set_updated_at();
