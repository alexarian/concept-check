-- Concept Check: ONE file. Paste all of it into Supabase SQL Editor and Run once.
-- Last result should show: 7 topics / 105 cases / 210 key points / 0

create table if not exists learners (
  id bigint generated always as identity primary key,
  label text not null,
  consent boolean not null default false,
  created_at timestamptz default now()
);

create table if not exists topics (
  id bigint generated always as identity primary key,
  title text not null
);

create table if not exists cases (
  id bigint generated always as identity primary key,
  topic_id bigint references topics(id),
  code text,
  question text not null
);

create table if not exists key_points (
  id bigint generated always as identity primary key,
  case_id bigint references cases(id),
  point text not null
);

create table if not exists gaps (
  id bigint generated always as identity primary key,
  learner_id bigint references learners(id),
  topic_id bigint references topics(id),
  explanation text,
  recited_sentence text,
  follow_up text,
  created_at timestamptz default now()
);

create table if not exists tries (
  id bigint generated always as identity primary key,
  gap_id bigint references gaps(id),
  case_id bigint references cases(id),
  stage text check (stage in ('before', 'after')),
  said text,
  passed boolean,
  created_at timestamptz default now()
);

create table if not exists ticks (
  id bigint generated always as identity primary key,
  try_id bigint references tries(id),
  key_point_id bigint references key_points(id),
  found boolean not null,
  quote text
);

alter table tries add column if not exists attempt smallint not null default 0
  check (attempt between 0 and 3);
alter table tries add column if not exists recited_sentence text;
alter table tries add column if not exists follow_up text;
alter table tries add column if not exists follow_up_reply text;
alter table gaps add column if not exists status text not null default 'in_progress'
  check (status in ('in_progress', 'closed', 'not_yet', 'no_gap'));
create table if not exists case_flags (
  id bigint generated always as identity primary key,
  case_id bigint references cases(id),
  learner_id bigint references learners(id),
  reason text check (reason in ('unclear', 'not_taught')),
  created_at timestamptz default now()
);

-- Concept Check seed: 7 topics, 105 cases, key points (topic 5 first).
-- Run in Supabase SQL Editor AFTER the base tables (Concept Check - Database, Step 4).
-- Safe to run twice: existing topics, cases and key points are skipped.

alter table topics add column if not exists explain_question text;
create unique index if not exists topics_title_key on topics (title);
create unique index if not exists cases_code_key on cases (code);
create unique index if not exists key_points_case_point_key on key_points (case_id, point);

begin;

-- Topics
insert into topics (title, explain_question) values ('What is an interface', 'What is an interface, and why can''t two systems just talk without one?') on conflict (title) do nothing;
insert into topics (title, explain_question) values ('PRD to UI to frontend', 'How do you get from a PRD to screens? Why not start with the screens?') on conflict (title) do nothing;
insert into topics (title, explain_question) values ('API as the second interface', 'What does one API call carry, and what does the reply tell you?') on conflict (title) do nothing;
insert into topics (title, explain_question) values ('Building APIs and backend', 'What does the backend actually do between the user''s input and the answer?') on conflict (title) do nothing;
insert into topics (title, explain_question) values ('Databases and domain modelling', 'Why does the app forget without storage, and how do you decide what to store?') on conflict (title) do nothing;
insert into topics (title, explain_question) values ('Connect backend to database', 'What has to happen for data to survive a refresh, and where does the key live?') on conflict (title) do nothing;
insert into topics (title, explain_question) values ('End to end MVP and deploy', 'What does it take for a real user to use your app on a live link?') on conflict (title) do nothing;

-- Topic 5: Databases and domain modelling
insert into cases (topic_id, code, question) select id, '5.1', 'In a library app, one member borrows many books over time and one book is borrowed by many members. How do you store borrowing?' from topics where title = 'Databases and domain modelling' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '5.2', 'In a society app, a flat has many residents and each resident lives in one flat. Where does the pointer go?' from topics where title = 'Databases and domain modelling' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '5.3', 'A classmate stores `resident_ids = "4,9,12"` in the flat''s row. Problem?' from topics where title = 'Databases and domain modelling' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '5.4', 'A gym membership can be active, paused or expired. Three tables or one?' from topics where title = 'Databases and domain modelling' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '5.5', 'Now the gym wants every date a membership was paused and resumed. Is the status cell still enough?' from topics where title = 'Databases and domain modelling' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '5.6', 'A tiffin customer uploads a photo of a bad meal. Where does the photo go?' from topics where title = 'Databases and domain modelling' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '5.7', 'In a recipe app, is "spicy" a table or a column?' from topics where title = 'Databases and domain modelling' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '5.8', 'Two customers are both named "Rohit Sharma." How does the app tell them apart?' from topics where title = 'Databases and domain modelling' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '5.9', 'In a music app, a song sits at position 3 in one playlist and position 8 in another. Where does "position" go?' from topics where title = 'Databases and domain modelling' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '5.10', 'A student tells a study bot "continue from where we stopped yesterday." It confidently talks about a different topic. Is the model broken?' from topics where title = 'Databases and domain modelling' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '5.11', 'To save server cost, a developer keeps each user''s chat history in the browser. The user clears their browser. What happens?' from topics where title = 'Databases and domain modelling' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '5.12', 'A startup with 1 user and a few saves a day pays for a vector database for "memory." Verdict?' from topics where title = 'Databases and domain modelling' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '5.13', 'A founder wants to store every click, location and contact of each user "just in case." Good idea?' from topics where title = 'Databases and domain modelling' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '5.14', 'Each employee must have exactly one ID card, and the system must refuse a second card for the same person. How?' from topics where title = 'Databases and domain modelling' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '5.15', 'A classmate models a to-do app with 12 tables, including `colours`, `weekdays` and `priority_levels`. Problem?' from topics where title = 'Databases and domain modelling' on conflict (code) do nothing;
insert into key_points (case_id, point)
select c.id, v.point from (values
  ('5.1', 'Stores borrowing in a separate table where each row pairs one member with one book (a pointer to each side)'),
  ('5.1', 'Explains why: both sides are many (a member borrows many books and a book is borrowed by many members), so neither the member nor the book row can hold the pointer without a list'),
  ('5.2', 'Puts the flat''s id on each resident''s row, not a list of resident ids on the flat'),
  ('5.2', 'Explains why: each resident lives in only one flat, so their row holds a single value, while a flat has many residents and would need a list'),
  ('5.3', 'Says the problem is several values (a list) stuffed into one cell'),
  ('5.3', 'Explains the fix: each resident gets their own row pointing to the flat, so every cell holds one value'),
  ('5.4', 'Chooses one table with a single status cell (active, paused or expired), not three tables'),
  ('5.4', 'Explains why: these are stages of the same membership, so the membership changes its status value instead of moving between tables'),
  ('5.5', 'Says the status cell alone is not enough'),
  ('5.5', 'Explains that each pause or resume must be saved as its own new row with a date, because overwriting the status cell erases the earlier changes'),
  ('5.6', 'Puts the photo itself in file storage, not inside a table row'),
  ('5.6', 'Explains that a row keeps only facts about the photo, such as its link, who sent it or when, because a table is for facts, not the image file'),
  ('5.7', 'Says spicy is a column (a fact about the recipe), or a table only if users can create and manage their own spice levels'),
  ('5.7', 'Explains the test: something gets its own table only if the app creates, changes and deletes many of them on their own; here spicy just describes the recipe'),
  ('5.8', 'Gives each customer a unique id and tells them apart by it'),
  ('5.8', 'Explains that names can repeat, so a name can''t point to one person, while an id is never shared (like a flat number)'),
  ('5.9', 'Puts position on the row that pairs a playlist with a song'),
  ('5.9', 'Explains that position describes that pairing: the same song has different positions in different playlists, so it can''t sit on the song or the playlist alone'),
  ('5.10', 'Says the model is not broken'),
  ('5.10', 'Explains that the model remembers nothing between chats: the system had to save yesterday''s chat, fetch it and send it with the new prompt, and it didn''t'),
  ('5.11', 'Says the chat history is lost'),
  ('5.11', 'Explains that the browser is on the user''s machine, which they control and can wipe (and anyone using it can read), so history the app needs belongs on the app''s server'),
  ('5.12', 'Says it is a waste: far more storage than this app needs right now'),
  ('5.12', 'Explains that with one user and a few saves a day a simple file is enough, and you move to bigger storage only when the file stops working'),
  ('5.13', 'Says no'),
  ('5.13', 'Explains to store only what the app''s questions actually need, because extra personal data costs money to keep and creates legal or privacy risk'),
  ('5.14', 'Makes the employee pointer on the cards table unique (or keeps the card in the employee''s own table)'),
  ('5.14', 'Explains that a unique pointer means the database itself refuses a second card for the same employee, so it enforces one card per person'),
  ('5.15', 'Says there are too many tables: most of these are facts that belong as columns'),
  ('5.15', 'Explains the test: colour, weekday and priority describe a to-do rather than being things the app manages on their own, so keep the smallest model that answers the app''s questions')
) as v(code, point)
join cases c on c.code = v.code
on conflict (case_id, point) do nothing;

-- Topic 1: What is an interface
insert into cases (topic_id, code, question) select id, '1.1', 'In a restaurant, the customer never meets the chef. The waiter writes the order on a slip in a fixed format and passes it to the kitchen. What is the interface between customer and kitchen?' from topics where title = 'What is an interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '1.2', 'A society notice-board machine accepts only fixed commands. 80 residents send commands at the same time and it makes mistakes. Will adding more command words fix it?' from topics where title = 'What is an interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '1.3', 'An old shopping-list machine only understands `ADD <item>`. You type "please add milk, thanks!" What happens?' from topics where title = 'What is an interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '1.4', 'A friend says "the interface of a food-delivery app is my phone''s screen glass." Right or wrong?' from topics where title = 'What is an interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '1.5', 'You open a food app inside Chrome. Is Chrome the UI?' from topics where title = 'What is an interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '1.6', 'A shopping app shows your past orders instantly. Does that list live on the screen itself?' from topics where title = 'What is an interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '1.7', 'You want to build "an app like a food-delivery app" but can''t name the machines behind it. Are you ready to build?' from topics where title = 'What is an interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '1.8', 'Your laptop runs macOS and a server runs Linux. They share no apps. Can they still exchange a web page? How?' from topics where title = 'What is an interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '1.9', 'You send a website a request asking "what did I ask you just before this?" and it has no idea. Is the website broken?' from topics where title = 'What is an interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '1.10', 'You send a popular meme to your grandmother, who has never seen the film it comes from. She is confused. Which part of the interface failed?' from topics where title = 'What is an interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '1.11', 'You pay a shop with a cheque. What are the two systems, and what is the interface?' from topics where title = 'What is an interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '1.12', 'A team builds its app for Android first, then finds most users are on iPhone. Why do they have to rebuild the UI?' from topics where title = 'What is an interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '1.13', 'You press Send in a chat app and the other person never gets the message. Your friend says "the UI is broken." Where else could it have broken?' from topics where title = 'What is an interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '1.14', 'A TV remote''s signal reaches a TV perfectly, but the remote is made for a different brand and nothing happens. Is there an interface?' from topics where title = 'What is an interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '1.15', 'At an ATM, what are the two systems, the language and the rules?' from topics where title = 'What is an interface' on conflict (code) do nothing;
insert into key_points (case_id, point)
select c.id, v.point from (values
  ('1.1', 'Says the interface is the whole waiter-and-slip system, not the slip or pen alone'),
  ('1.1', 'Explains that it gives both sides a shared language (menu item names) and fixed rules (slip format, order of steps), while the slip is only one part'),
  ('1.2', 'Says no, more command words won''t fix it'),
  ('1.2', 'Explains that the commands are already understood; the missing piece is rules for coordinating the people, such as one at a time or one point of contact'),
  ('1.3', 'Says nothing useful happens, or it gives an error'),
  ('1.3', 'Explains that the machine doesn''t guess: it only understands its exact command format, so an instruction outside that format fails and the fault is the sender''s'),
  ('1.4', 'Says wrong'),
  ('1.4', 'Explains that the glass is just a part; the interface is the app''s screen (UI), which gives a language like buttons and text and rules like tap and send'),
  ('1.5', 'Says no, Chrome is not the UI'),
  ('1.5', 'Explains that Chrome is the browser, an app of its own, and the food app''s screen that loads inside it is the UI'),
  ('1.6', 'Says no, the list doesn''t live on the screen'),
  ('1.6', 'Explains that the list comes from the company''s machine behind the screen, fetched through an API (for example, visible in the Network tab)'),
  ('1.7', 'Says no, not ready'),
  ('1.7', 'Explains that if you can''t name the systems behind an app, you can''t build one like it, so you first inspect which machines it uses'),
  ('1.8', 'Says yes'),
  ('1.8', 'Explains how: they share a common language for the page (HTML) and common rules for sending it (HTTP), on top of the binary every machine understands'),
  ('1.9', 'Says not necessarily broken'),
  ('1.9', 'Explains that each request arrives on its own with no memory of earlier ones, so remembering needs something extra, like storage'),
  ('1.10', 'Says the shared context failed: she lacks the film knowledge the meme relies on'),
  ('1.10', 'Explains that the template arrived fine (the rules worked), but the common language, the knowledge both sides must share, was missing'),
  ('1.11', 'Names the two systems (you or your bank, and the shop''s bank) and says the interface is the cheque clearing system, not the paper alone'),
  ('1.11', 'Explains that it supplies a shared language (amounts, names, account numbers) and rules (signature, date, clearing steps)'),
  ('1.12', 'Says the device and operating system underneath changed, and those decide what the UI can do'),
  ('1.12', 'Explains that the UI sits on top of the device and its operating system, so when those lower layers change, the UI has to be rebuilt for them'),
  ('1.13', 'Names at least one place behind the UI where it could break: the browser, the internet connection, the API call, or the company''s machine'),
  ('1.13', 'Explains that the message passes through several systems, each with its own interface, and any one of them can fail, not only the screen'),
  ('1.14', 'Says no, there is no interface'),
  ('1.14', 'Explains that the signal arriving is only a part working; the remote and TV share no common language or rules, so the TV can''t understand it'),
  ('1.15', 'Names the two systems: you and the bank''s machine'),
  ('1.15', 'Says the language is the screen''s buttons and numbers, and the rules are the fixed order of steps (card, then PIN, then amount)')
) as v(code, point)
join cases c on c.code = v.code
on conflict (case_id, point) do nothing;

-- Topic 2: PRD to UI to frontend
insert into cases (topic_id, code, question) select id, '2.1', 'A tiffin-service founder asks Stitch for "a beautiful home screen" before deciding who the user is. What goes wrong?' from topics where title = 'PRD to UI to frontend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '2.2', 'A gym-app team picks 20 components from a library first, then tries to fit them into screens. Problem?' from topics where title = 'PRD to UI to frontend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '2.3', 'A plant-care app looks stunning, but users can''t find the "log watering" button. Will better colours fix it?' from topics where title = 'PRD to UI to frontend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '2.4', 'A clinic app''s AI step that predicts waiting time fails, but the screen still shows "15 min" confidently. Better or worse than showing nothing?' from topics where title = 'PRD to UI to frontend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '2.5', 'The "My bookings" screen is plain white for a brand-new user with no bookings. What did the designer forget?' from topics where title = 'PRD to UI to frontend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '2.6', 'A tuition-class app involves parents (pay), the tutor (marks attendance) and students (see homework). The team interviewed only students. Risk?' from topics where title = 'PRD to UI to frontend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '2.7', 'A street-food vendor''s customers browse the menu at home on any phone and don''t want to install anything from an app store. Native app, PWA or WhatsApp?' from topics where title = 'PRD to UI to frontend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '2.8', 'The same vendor wants customers to compare four combo meals side by side. Someone suggests doing everything in WhatsApp chat. Good as the main channel?' from topics where title = 'PRD to UI to frontend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '2.9', 'A designer makes one layout for both phone and desktop for an accounts dashboard. Problem?' from topics where title = 'PRD to UI to frontend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '2.10', 'A learning app for 6-year-olds uses a dense, text-heavy editorial style. Problem?' from topics where title = 'PRD to UI to frontend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '2.11', 'A classmate types only "make a salon app" into Stitch, with no PRD or design.md. The result ignores the brand. Why?' from topics where title = 'PRD to UI to frontend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '2.12', 'A classmate builds in AI Studio without saying "Android" in the first prompt, then later asks "make it Android." What happens?' from topics where title = 'PRD to UI to frontend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '2.13', 'A classmate keeps adjusting colours and spacing inside the AI Studio Android build and runs out of credits. Better approach?' from topics where title = 'PRD to UI to frontend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '2.14', 'Stitch''s first output has four equally loud buttons on the home screen. Which review checks does it fail, and what do you do?' from topics where title = 'PRD to UI to frontend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '2.15', 'A salon-app founder wants AI captions, loyalty points, chat and payments in version 1. Which product decision is missing?' from topics where title = 'PRD to UI to frontend' on conflict (code) do nothing;
insert into key_points (case_id, point)
select c.id, v.point from (values
  ('2.1', 'Says the design will be generic or made for the wrong person'),
  ('2.1', 'Explains that you first decide the user and their problem, then the product decisions, and only then design screens'),
  ('2.2', 'Says they are working backwards'),
  ('2.2', 'Explains the right order: map the user''s flow first, design screens from that flow, then pick the components those screens need'),
  ('2.3', 'Says no, better colours won''t fix it'),
  ('2.3', 'Explains that the problem is what happens (users can''t find or reach the action), not how it looks, and good visuals can''t rescue a broken experience'),
  ('2.4', 'Says worse'),
  ('2.4', 'Explains that a confident wrong number misleads the patient into acting on it, so the screen needs an error state saying the prediction failed'),
  ('2.5', 'Says the designer forgot the empty state'),
  ('2.5', 'Explains that every screen needs a state for when there''s no data yet, telling a new user what is happening and what to do next'),
  ('2.6', 'Says the risk is missing the other people involved (parents, tutor), whose actions the app depends on'),
  ('2.6', 'Explains that every person who needs or does something must be mapped, because if one of them, like the tutor, doesn''t act, the product fails for everyone'),
  ('2.7', 'Chooses a PWA'),
  ('2.7', 'Explains that it opens on any phone through the browser and can be added to the home screen without an app store'),
  ('2.8', 'Says no, not as the main channel'),
  ('2.8', 'Explains that comparing options side by side is hard in a back-and-forth chat, so a structured view such as a menu page works better'),
  ('2.9', 'Says one layout for both won''t suit either well'),
  ('2.9', 'Explains that people use phones and desktops differently (thumb, narrow and focused versus keyboard, pointer, wide and dense), so each needs its own design'),
  ('2.10', 'Says the design style is wrong for this user'),
  ('2.10', 'Explains that the style must be chosen for the target user, and young children need something simple and visual, not dense text'),
  ('2.11', 'Says the tool had nothing specific to go on, so it guessed something generic'),
  ('2.11', 'Explains that giving it structured input (a PRD and a design.md about the users, screens and brand) is what makes the output specific'),
  ('2.12', 'Says it was built as a web app, so they likely have to start again'),
  ('2.12', 'Explains that web is the default and Android is a different codebase, so the platform must be stated in the first prompt'),
  ('2.13', 'Says to finish visual changes in Stitch first, then build'),
  ('2.13', 'Explains that visual edits are cheap and fast in Stitch but slow and costly in credits inside the AI Studio Android build'),
  ('2.14', 'Says it fails on hierarchy: there is no single clear first action'),
  ('2.14', 'Says the fix is to keep one main action and change or remove the other buttons'),
  ('2.15', 'Says the missing decision is what NOT to build in version 1'),
  ('2.15', 'Explains to pick the one critical moment the app must get right and build only what that moment needs')
) as v(code, point)
join cases c on c.code = v.code
on conflict (case_id, point) do nothing;

-- Topic 3: API as the second interface
insert into cases (topic_id, code, question) select id, '3.1', 'You POST to Aarav''s service but type `/aarav/diagnosiss` (extra "s"). Which code comes back?' from topics where title = 'API as the second interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '3.2', 'Right address, but your key is missing its last character. Which code?' from topics where title = 'API as the second interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '3.3', 'A homework app sends a new submission to its server. Which action, and which success code to expect?' from topics where title = 'API as the second interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '3.4', 'The same app loads today''s homework list. Which action and code?' from topics where title = 'API as the second interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '3.5', 'A student fixes one spelling mistake in a homework title. PUT or PATCH?' from topics where title = 'API as the second interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '3.6', 'Ten classmates hit the same small service in the same second with one shared key. Many get an error. Which code, most likely?' from topics where title = 'API as the second interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '3.7', 'Aarav''s service expects `{"workflow": "..."}`. You send `{"task": "..."}`. What happens?' from topics where title = 'API as the second interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '3.8', 'In `google.com/search?q=best biryani`, what does `?q=` do, and what happens to the space?' from topics where title = 'API as the second interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '3.9', 'A team of 5 shares one API key between them. What''s the problem?' from topics where title = 'API as the second interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '3.10', 'Your request is perfect, but someone''s service returns 500. Whose fault?' from topics where title = 'API as the second interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '3.11', 'On an image-generator site you type a prompt and get a brand-new image. GET or POST?' from topics where title = 'API as the second interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '3.12', 'You call a weather service with only `https://api.weather-example.com` and no path. What''s missing?' from topics where title = 'API as the second interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '3.13', 'Before reading any docs, a classmate starts writing English sentences to a new service. What should come first?' from topics where title = 'API as the second interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '3.14', 'In the Network tab, a site''s POST returns 200, not 201. Is the site "wrong"?' from topics where title = 'API as the second interface' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '3.15', 'A joke service lets anyone read jokes with no key, but its paid "write me a new joke" door needs a key. Why the difference?' from topics where title = 'API as the second interface' on conflict (code) do nothing;
insert into key_points (case_id, point)
select c.id, v.point from (values
  ('3.1', 'Says 404'),
  ('3.1', 'Explains that the address (path) is wrong, so there is nothing at that location to reach'),
  ('3.2', 'Says 401'),
  ('3.2', 'Explains that the address is right but the key isn''t recognised, so the server can''t confirm who you are'),
  ('3.3', 'Says POST, expecting 201'),
  ('3.3', 'Explains that a new submission is being created, and 201 means something new was created'),
  ('3.4', 'Says GET, expecting 200'),
  ('3.4', 'Explains that the list already exists and is only being read; nothing new is created'),
  ('3.5', 'Says PATCH'),
  ('3.5', 'Explains that PATCH changes just one part, while PUT replaces the whole thing'),
  ('3.6', 'Says 429'),
  ('3.6', 'Explains that too many requests arrived at once, and the service limits how many it accepts'),
  ('3.7', 'Says it returns an error (a 4xx, likely 400), not a plan'),
  ('3.7', 'Explains that the package doesn''t match what the service expects, and the machine won''t guess that task means workflow'),
  ('3.8', 'Says ?q= passes the search words as a query parameter (a filter on the same page), and the space becomes %20'),
  ('3.8', 'Explains that a space would be ambiguous inside a web address, so it has to be encoded'),
  ('3.9', 'Says the server can''t tell the five people apart'),
  ('3.9', 'Explains that a key identifies one caller, so with a shared key nobody knows who did what, and one leak lets anyone spend the money'),
  ('3.10', 'Says it is their server''s fault'),
  ('3.10', 'Explains that a 5xx code means the other machine failed, while a 4xx would mean you sent something wrong'),
  ('3.11', 'Says POST'),
  ('3.11', 'Explains that generating a brand-new image is creating something, not reading something that already exists'),
  ('3.12', 'Says the path (the endpoint) is missing'),
  ('3.12', 'Explains that the domain only finds the machine; the path says which resource on it you want'),
  ('3.13', 'Says first find the service''s language and rules by reading its docs'),
  ('3.13', 'Explains that the machine won''t guess what plain sentences mean, so you must know what it accepts before sending anything'),
  ('3.14', 'Says not necessarily wrong'),
  ('3.14', 'Explains that real companies bend the conventions, so the Network tab shows what actually happens, and you should be able to justify your own choice'),
  ('3.15', 'Says reading is open but generating is gated behind a key'),
  ('3.15', 'Explains that generating costs the service money, so it needs to know who is asking before doing that work')
) as v(code, point)
join cases c on c.code = v.code
on conflict (case_id, point) do nothing;

-- Topic 4: Building APIs and backend
insert into cases (topic_id, code, question) select id, '4.1', 'A classmate''s app, moved into Antigravity, replies with exactly what the user typed. What''s missing?' from topics where title = 'Building APIs and backend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '4.2', 'Your app returns 200 and a long plan, but your user, a nurse, can''t understand the jargon. Done?' from topics where title = 'Building APIs and backend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '4.3', 'You want to test your app''s "create a plan" door by pasting its URL into the browser address bar. Will that create a plan?' from topics where title = 'Building APIs and backend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '4.4', 'After the agent wires your app to an LLM, every request returns 404 "model does not exist." Whose fault, and what?' from topics where title = 'Building APIs and backend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '4.5', 'Your app calls Groq. You ask the agent to switch to OpenAI, and its plan rewrites the whole app. Approve?' from topics where title = 'Building APIs and backend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '4.6', 'Your app works in Antigravity, but you can''t say which address, action or key it sends to the LLM. What''s the risk?' from topics where title = 'Building APIs and backend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '4.7', 'The agent''s plan says "Step 3: connect to the LLM API." You approve, and nothing visible changes. What should you have done first?' from topics where title = 'Building APIs and backend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '4.8', 'A fitness-coach app sends the LLM an instruction plus the user''s message. Which part stays the same every call, and which changes?' from topics where title = 'Building APIs and backend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '4.9', 'On a free tier of 30 requests a minute, 30 users each send 2 requests in the same minute. What happens?' from topics where title = 'Building APIs and backend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '4.10', 'You ask the agent to "add one LLM call." Its plan also adds a login page, a dashboard and three new tables. Approve everything?' from topics where title = 'Building APIs and backend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '4.11', 'A classmate is about to ask the agent to build a resume-review app, but hasn''t talked to any job seeker and can''t say what a good review looks like. Should they build?' from topics where title = 'Building APIs and backend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '4.12', 'Your plans are correct but drift into technical jargon Aarav can''t use. Fix it by rebuilding the app, or by changing the prompt?' from topics where title = 'Building APIs and backend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '4.13', 'You send the same input to your app twice and get two different plans. Is that the deterministic part of the system?' from topics where title = 'Building APIs and backend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '4.14', 'You want your app to email the plan through a mail service. What four things do you find out before asking the agent to wire it?' from topics where title = 'Building APIs and backend' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '4.15', '"The agent builds everything, so why understand requests?" A bug appears and the agent can''t fix it after 5 rounds. Why?' from topics where title = 'Building APIs and backend' on conflict (code) do nothing;
insert into key_points (case_id, point)
select c.id, v.point from (values
  ('4.1', 'Says the process step is missing'),
  ('4.1', 'Explains that the app passes input straight to output; nothing in between turns the input into something useful'),
  ('4.2', 'Says no, not done'),
  ('4.2', 'Explains that 200 only means the machine accepted the request, not that the output helped this user, so it must be checked against what the nurse actually needs'),
  ('4.3', 'Says no, it won''t create a plan'),
  ('4.3', 'Explains that the address bar only sends a GET, which reads; creating something new needs a POST'),
  ('4.4', 'Says it is the request''s fault (a 4xx), not the provider''s server'),
  ('4.4', 'Explains that the model name in the request is wrong or retired, so check the provider''s own docs for a current name'),
  ('4.5', 'Says reject the plan'),
  ('4.5', 'Explains that switching provider only needs a new address and key; the prompt and the rest of the app stay the same'),
  ('4.6', 'Says the risk is that when it breaks, you can''t find or fix the problem'),
  ('4.6', 'Explains that without knowing the address, action and key the app sends, you can''t check what''s wrong or tell the agent what to change'),
  ('4.7', 'Says decide first what you''d see if the step worked (for example, a plan appearing for a test input)'),
  ('4.7', 'Explains that without that check you can''t tell whether the step actually worked before moving on'),
  ('4.8', 'Says the instruction stays the same and the user''s message changes'),
  ('4.8', 'Explains that the instruction is the builder''s fixed part of the package, while the input comes from each user and varies'),
  ('4.9', 'Says some requests get refused because of the rate limit'),
  ('4.9', 'Explains that 60 requests exceed the 30-a-minute cap, so the builder has to plan usage per user'),
  ('4.10', 'Says reject the extra steps and approve only the one LLM call'),
  ('4.10', 'Explains to take the smallest change asked for, because extra pieces you didn''t ask for are things you don''t understand and can''t check'),
  ('4.11', 'Says no, not yet'),
  ('4.11', 'Explains that without a real user and examples of good output, they can''t tell whether the app''s reviews are good or bad'),
  ('4.12', 'Says change the prompt'),
  ('4.12', 'Explains that the app already works; the problem is the instruction, so telling it to avoid jargon fixes the output without rebuilding'),
  ('4.13', 'Says no'),
  ('4.13', 'Explains that deterministic means the same input always gives the same output; the difference comes from the LLM, whose output has to be checked by judgment'),
  ('4.14', 'Names the four: the address, the action, the key (and how to get it), and the package'),
  ('4.14', 'Explains that every machine is reached the same way, so these must be known before the agent can wire it correctly'),
  ('4.15', 'Says the cause is that the builder doesn''t understand how the app''s requests work (understanding debt)'),
  ('4.15', 'Explains that you can''t check the agent''s fixes or explain the problem to it if you don''t understand it yourself')
) as v(code, point)
join cases c on c.code = v.code
on conflict (case_id, point) do nothing;

-- Topic 6: Connect backend to database
insert into cases (topic_id, code, question) select id, '6.1', 'The agent''s plan puts your Groq key inside the web page "so the call is faster." Approve?' from topics where title = 'Connect backend to database' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '6.2', 'Where should the Supabase secret key be kept in your app?' from topics where title = 'Connect backend to database' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '6.3', 'Row Level Security isn''t switched on yet. Can the publishable key go in the page?' from topics where title = 'Connect backend to database' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '6.4', 'The agent says "Supabase connected." You save a plan and refresh the page, and the plan is gone. Is the step done?' from topics where title = 'Connect backend to database' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '6.5', 'The agent''s plan opens Supabase and starts creating tables before you''ve drawn your model on paper. Approve?' from topics where title = 'Connect backend to database' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '6.6', 'The agent''s plan stores the user''s name inside every workflow row instead of a `user_id`. Approve?' from topics where title = 'Connect backend to database' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '6.7', 'One user can have many workflows. The agent''s plan puts a `workflow_id` column on the users table. Approve?' from topics where title = 'Connect backend to database' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '6.8', 'The agent''s plan saves each new plan into one `plan` cell on the workflow, replacing the old one. Problem?' from topics where title = 'Connect backend to database' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '6.9', 'Your app lets users upload a screenshot. The agent''s plan saves the image inside a text column. Approve?' from topics where title = 'Connect backend to database' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '6.10', 'You ask the agent to move storage from a file to Supabase. Its plan also rewrites the prompt and the UI. Approve?' from topics where title = 'Connect backend to database' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '6.11', 'To make an error go away, the agent offers to paste the key straight into the code, and your repo is public. Approve?' from topics where title = 'Connect backend to database' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '6.12', 'Your app sends the text "twenty" into a number column in Supabase. What happens?' from topics where title = 'Connect backend to database' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '6.13', 'Your backend must save a new plan to Supabase. What are the address, action, key and package?' from topics where title = 'Connect backend to database' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '6.14', 'Your page now calls your own backend, and the backend calls Groq. Does the page still need the Groq key?' from topics where title = 'Connect backend to database' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '6.15', 'A user wants the output as a Google Sheet. The agent''s plan builds the spreadsheet file inside your API. Better approach?' from topics where title = 'Connect backend to database' on conflict (code) do nothing;
insert into key_points (case_id, point)
select c.id, v.point from (values
  ('6.1', 'Says reject'),
  ('6.1', 'Explains that anything in the web page can be read by anyone (page source or Network tab), so the key could be copied to spend your money; it must stay on the server'),
  ('6.2', 'Says it is kept on the backend, in environment variables, never in the page'),
  ('6.2', 'Explains that the secret key can read and write everything, so it must stay on the server where users can''t see it'),
  ('6.3', 'Says not yet'),
  ('6.3', 'Explains that the publishable key is only safe in the page once Row Level Security limits which rows each user can reach'),
  ('6.4', 'Says no, not done'),
  ('6.4', 'Explains that done means the data survives a refresh: the row must be saved in the Supabase table and read back by the app'),
  ('6.5', 'Says pause and draw the model on paper first'),
  ('6.5', 'Explains that the tables should come from the model of things, facts and links, not be created before you know what they are'),
  ('6.6', 'Says reject: use the user''s id instead of the name'),
  ('6.6', 'Explains that two users can share a name, so a name can''t reliably point to one user, while an id is unique'),
  ('6.7', 'Says reject: put the user''s id on the workflows table instead'),
  ('6.7', 'Explains that one user has many workflows, so a single cell on the user''s row can''t hold them all; the pointer goes on the many side'),
  ('6.8', 'Says the old plans are lost'),
  ('6.8', 'Explains that each plan should be saved as its own new row with a time, because overwriting one cell erases the history'),
  ('6.9', 'Says reject: the image goes to file storage'),
  ('6.9', 'Explains that the row should keep only facts about the image, such as its link, who sent it and when, not the image itself'),
  ('6.10', 'Says reject the extra changes'),
  ('6.10', 'Explains that only the storage part needed to change; the prompt and UI are separate parts that should stay as they are'),
  ('6.11', 'Says reject'),
  ('6.11', 'Explains that a key in the code of a public repo is visible to everyone, so it must stay in environment variables (and a leaked key must be revoked and replaced)'),
  ('6.12', 'Says it is refused (an error)'),
  ('6.12', 'Explains that the column''s type only accepts numbers, and the database checks every value against it'),
  ('6.13', 'Gives all four: the Supabase project address (and table), POST to create, the secret key kept on the server, and the new row as JSON'),
  ('6.13', 'Explains that the database is just another machine at an address, reached the same way as any API'),
  ('6.14', 'Says no'),
  ('6.14', 'Explains that the page only talks to your backend, and the backend is the one calling Groq, so only the backend needs the key'),
  ('6.15', 'Says send the data as JSON and turn it into a spreadsheet on the user''s side'),
  ('6.15', 'Explains that the API should stay thin and return the content; making the file format is a separate job')
) as v(code, point)
join cases c on c.code = v.code
on conflict (case_id, point) do nothing;

-- Topic 7: End to end MVP and deploy
insert into cases (topic_id, code, question) select id, '7.1', 'A classmate shares a link starting with `localhost` or `127.0.0.1` for review. What will the reviewer see?' from topics where title = 'End to end MVP and deploy' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '7.2', 'You push an untested change to the live app while your real user is using it, and it breaks. Lesson?' from topics where title = 'End to end MVP and deploy' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '7.3', 'Your app works in Antigravity''s preview on your laptop. What has to happen before a real user can use it?' from topics where title = 'End to end MVP and deploy' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '7.4', 'The deployed app returns 500, but it worked in preview. Which item on the deploy checklist do you check first?' from topics where title = 'End to end MVP and deploy' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '7.5', 'You added the environment variable on Vercel and still get 500. What did you miss?' from topics where title = 'End to end MVP and deploy' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '7.6', 'Your live app errors for a user. Where on Vercel do you look first?' from topics where title = 'End to end MVP and deploy' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '7.7', 'Two cashiers in a canteen app save orders to one file at the same moment. Both see success, but one order is missing. Why?' from topics where title = 'End to end MVP and deploy' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '7.8', 'A personal blog has 10,000 readers, and only the owner ever writes. File or database?' from topics where title = 'End to end MVP and deploy' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '7.9', 'A habit-tracker MVP tests "6 of 10 users log a habit for 7 days." What do you store first?' from topics where title = 'End to end MVP and deploy' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '7.10', 'Should one workflow allow one plan or many? A classmate guesses "many."' from topics where title = 'End to end MVP and deploy' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '7.11', 'Mira logs into the live app and can see Aarav''s workflows. What''s missing?' from topics where title = 'End to end MVP and deploy' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '7.12', 'Your user completes the task on the live link, refreshes, and their result is gone. Is the MVP done?' from topics where title = 'End to end MVP and deploy' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '7.13', 'Before handing over the live link, you open the Network tab and see your Groq key in a request. Ready to share?' from topics where title = 'End to end MVP and deploy' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '7.14', 'You post a screenshot of your app working and call it done. Is it?' from topics where title = 'End to end MVP and deploy' on conflict (code) do nothing;
insert into cases (topic_id, code, question) select id, '7.15', 'Your tester is the friend who helped you build the app. Does that meet L8''s done?' from topics where title = 'End to end MVP and deploy' on conflict (code) do nothing;
insert into key_points (case_id, point)
select c.id, v.point from (values
  ('7.1', 'Says the reviewer sees nothing: the link won''t open for them'),
  ('7.1', 'Explains that localhost means the sender''s own machine, so the link only works there; anything shared has to be deployed'),
  ('7.2', 'Says test before pushing changes live'),
  ('7.2', 'Explains that testing on the live app means the real user pays for your mistakes'),
  ('7.3', 'Says deploy it (to Vercel) and share the live link'),
  ('7.3', 'Explains that the preview only runs on the builder''s machine, and done means a real user completes the task on the deployed link'),
  ('7.4', 'Says check the environment variables and keys on Vercel first'),
  ('7.4', 'Explains that a 500 means the server failed, often because the key it needs isn''t on Vercel''s machine even though it was on the laptop'),
  ('7.5', 'Says you missed redeploying'),
  ('7.5', 'Explains that a new environment variable is only picked up after the app is redeployed'),
  ('7.6', 'Says the project''s Logs on Vercel'),
  ('7.6', 'Explains that the logs show each request''s trip and where it failed'),
  ('7.7', 'Says both wrote at the same moment and the last write overwrote the other (a race condition)'),
  ('7.7', 'Explains that a single file can''t handle several people writing at once, so a database like Supabase is needed'),
  ('7.8', 'Says a file is fine'),
  ('7.8', 'Explains that only the owner writes and everyone else just reads, and reading a file scales easily; many people writing is what needs a database'),
  ('7.9', 'Says store the user, the habit and each log entry (each with an id and a time)'),
  ('7.9', 'Explains to store only what tests the bet, so skip extras like profiles or badges'),
  ('7.10', 'Says it isn''t something to guess; start simple and test with users'),
  ('7.10', 'Explains that one or many should come from what users actually need, keeping the simpler option unless they need the other'),
  ('7.11', 'Says a Row Level Security policy is missing'),
  ('7.11', 'Explains that without it the database doesn''t limit which rows each user can read, so anyone logged in can see everyone''s data'),
  ('7.12', 'Says no'),
  ('7.12', 'Explains that the result must survive a refresh, which means it is saved in Supabase and read back by the app'),
  ('7.13', 'Says no'),
  ('7.13', 'Explains that the key is visible to every visitor, so it must move to the backend''s environment variables, then redeploy and check the Network tab again'),
  ('7.14', 'Says no'),
  ('7.14', 'Explains that done means a real user who didn''t build it completes the task on the deployed link, not a screenshot'),
  ('7.15', 'Says no'),
  ('7.15', 'Explains that the tester must be someone who didn''t build it, to show a stranger can use it without the builder''s help')
) as v(code, point)
join cases c on c.code = v.code
on conflict (case_id, point) do nothing;

commit;

-- Check: expect 7 topics, 105 cases, 210 key points, 0 cases without points
select (select count(*) from topics) as topics, (select count(*) from cases) as cases,
       (select count(*) from key_points) as key_points,
       (select count(*) from cases c where not exists (select 1 from key_points k where k.case_id = c.id)) as cases_without_points;
