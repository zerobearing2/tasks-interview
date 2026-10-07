# This file seeds the database with a starting set of users and tasks. Load it
# with `bin/rails db:seed` (or alongside db:create via `bin/rails db:setup`).
#
# All accounts share the password "abc123" so any of them can be used to log in.

[
  "Ada Lovelace",
  "Grace Hopper",
  "Katherine Johnson",
  "Alan Turing",
  "Edsger Dijkstra"
].each_with_index do |name, index|
  User.where(email: "user#{index + 1}@tern.travel").first_or_create!(
    name: name,
    password: "abc123",
    password_confirmation: "abc123"
  )
end

# Titles intentionally vary in casing, length, and shared substrings (several
# "Book ...", two "... client ...") so filtering and sorting have something real
# to chew on. A few descriptions are left blank to exercise the index view's
# nil-safe truncation.
tasks = [
  {title: "Book flights to Lisbon", complete: true, description: "Outbound May 3, return May 17. Aisle seats for both legs."},
  {title: "Book hotel in Kyoto", complete: false, description: "Ryokan near Gion, 4 nights, breakfast included."},
  {title: "Book airport transfer", complete: false, description: nil},
  {title: "Confirm client itinerary", complete: false, description: "Send the day-by-day plan to the Hendricks party for sign-off."},
  {title: "Email client welcome packet", complete: true, description: "Visa reminders, packing list, emergency contacts."},
  {title: "Renew passport", complete: false, description: "Expedited — current one expires in under six months."},
  {title: "Update travel insurance", complete: false, description: nil},
  {title: "Draft Q3 trip budget", complete: false, description: "Roll up supplier quotes and a 12% contingency."},
  {title: "Review supplier contracts", complete: true, description: "Check cancellation windows before the deposit deadline."},
  {title: "Schedule team offsite", complete: false, description: "Two days, somewhere reachable by train for everyone."},
  {title: "Reconcile expense report", complete: false, description: "March card statement against the receipts folder."},
  {title: "Plan Patagonia route", complete: false, description: "El Chaltén to Torres del Paine, padding for weather days."},
  {title: "Order currency for Japan", complete: false, description: nil},
  {title: "Sync with ground operator", complete: true, description: "Confirm the driver and guide for the Marrakech leg."},
  {title: "Archive old itineraries", complete: false, description: "Anything from last season can move to cold storage."},
  {title: "follow up with Lisbon hotel", complete: false, description: "Lowercase on purpose — still waiting on the room upgrade."}
]

tasks.each do |attributes|
  Task.where(title: attributes[:title]).first_or_create!(attributes.except(:title))
end

legacy_tasks = [
  {title: "Buy tickets: book the 9am AA flight to Cancun", complete: false},
  {title: "Call hotel: confirm the late checkout for the Rivera party", complete: false},
  {title: "Passport: renew before the Japan trip", complete: true},
  {title: "Insurance: add the Patagonia leg to the policy", complete: false}
]

legacy_tasks.each do |attributes|
  Task.where(title: attributes[:title]).first_or_create!(attributes.except(:title))
end

# One task per edge of the "Due Soon" window and the day-before reminder. Dates
# are relative to today and upserted, so re-running db:seed refreshes them and
# clears the sent-reminder stamp.
today = Date.current
user1 = User.find_by!(email: "user1@tern.travel")
user2 = User.find_by!(email: "user2@tern.travel")

due_date_tasks = [
  {title: "Due dates: overdue since yesterday", due_on: today - 1, assignee: user1, complete: false},
  {title: "Due dates: due today", due_on: today, assignee: user1, complete: false},
  {title: "Due dates: due tomorrow", due_on: today + 1, assignee: user1, complete: false},
  {title: "Due dates: due in 7 days", due_on: today + 7, assignee: user1, complete: false},
  {title: "Due dates: due in 8 days", due_on: today + 8, assignee: user1, complete: false},
  {title: "Due dates: completed, due tomorrow", due_on: today + 1, assignee: user1, complete: true},
  {title: "Due dates: unassigned, due tomorrow", due_on: today + 1, assignee: nil, complete: false},
  {title: "Due dates: assigned to user2, due in 2 days", due_on: today + 2, assignee: user2, complete: false}
]

due_date_tasks.each do |attributes|
  Task.find_or_initialize_by(title: attributes[:title]).update!(reminded_for: nil, **attributes.except(:title))
end
