require "application_system_test_case"

class TasksTest < ApplicationSystemTestCase
  test "visiting the index" do
    visit new_session_url

    fill_in "Email", with: users(:ada).email
    fill_in "Password", with: "abc123"

    click_on "Login"

    assert_selector "h1", text: "Tasks"
  end
end
