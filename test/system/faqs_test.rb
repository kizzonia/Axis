require "application_system_test_case"

class FaqsTest < ApplicationSystemTestCase
  setup do
    @faq = faqs(:one)
  end

  test "visiting the index" do
    visit faqs_url
    assert_selector "h1", text: "Faqs"
  end

  test "should create faq" do
    visit faqs_url
    click_on "New faq"

    fill_in "Body", with: @faq.body
    fill_in "Icon", with: @faq.icon
    fill_in "Slug", with: @faq.slug
    fill_in "Title", with: @faq.title
    click_on "Create Faq"

    assert_text "Faq was successfully created"
    click_on "Back"
  end

  test "should update Faq" do
    visit faq_url(@faq)
    click_on "Edit this faq", match: :first

    fill_in "Body", with: @faq.body
    fill_in "Icon", with: @faq.icon
    fill_in "Slug", with: @faq.slug
    fill_in "Title", with: @faq.title
    click_on "Update Faq"

    assert_text "Faq was successfully updated"
    click_on "Back"
  end

  test "should destroy Faq" do
    visit faq_url(@faq)
    click_on "Destroy this faq", match: :first

    assert_text "Faq was successfully destroyed"
  end
end
