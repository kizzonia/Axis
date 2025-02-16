require "application_system_test_case"

class HelpsTest < ApplicationSystemTestCase
  setup do
    @help = helps(:one)
  end

  test "visiting the index" do
    visit helps_url
    assert_selector "h1", text: "Helps"
  end

  test "should create help" do
    visit helps_url
    click_on "New help"

    fill_in "Body", with: @help.body
    fill_in "Slug", with: @help.slug
    fill_in "Sub title", with: @help.sub_title
    fill_in "Title", with: @help.title
    click_on "Create Help"

    assert_text "Help was successfully created"
    click_on "Back"
  end

  test "should update Help" do
    visit help_url(@help)
    click_on "Edit this help", match: :first

    fill_in "Body", with: @help.body
    fill_in "Slug", with: @help.slug
    fill_in "Sub title", with: @help.sub_title
    fill_in "Title", with: @help.title
    click_on "Update Help"

    assert_text "Help was successfully updated"
    click_on "Back"
  end

  test "should destroy Help" do
    visit help_url(@help)
    click_on "Destroy this help", match: :first

    assert_text "Help was successfully destroyed"
  end
end
