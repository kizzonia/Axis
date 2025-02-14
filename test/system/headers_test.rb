require "application_system_test_case"

class HeadersTest < ApplicationSystemTestCase
  setup do
    @header = headers(:one)
  end

  test "visiting the index" do
    visit headers_url
    assert_selector "h1", text: "Headers"
  end

  test "should create header" do
    visit headers_url
    click_on "New header"

    fill_in "Abouts sub title", with: @header.abouts_sub_title
    fill_in "Abouts title", with: @header.abouts_title
    fill_in "Blogs sub title", with: @header.blogs_sub_title
    fill_in "Blogs title", with: @header.blogs_title
    fill_in "Boards sub title", with: @header.boards_sub_title
    fill_in "Boards title", with: @header.boards_title
    fill_in "Cta1", with: @header.cta1
    fill_in "Cta2", with: @header.cta2
    fill_in "Features sub title", with: @header.features_sub_title
    fill_in "Features title", with: @header.features_title
    fill_in "Feedbacks sub title", with: @header.feedbacks_sub_title
    fill_in "Feedbacks title", with: @header.feedbacks_title
    fill_in "Headerimg", with: @header.headerimg
    fill_in "Products sub title", with: @header.products_sub_title
    fill_in "Products title", with: @header.products_title
    fill_in "Services sub title", with: @header.services_sub_title
    fill_in "Services title", with: @header.services_title
    click_on "Create Header"

    assert_text "Header was successfully created"
    click_on "Back"
  end

  test "should update Header" do
    visit header_url(@header)
    click_on "Edit this header", match: :first

    fill_in "Abouts sub title", with: @header.abouts_sub_title
    fill_in "Abouts title", with: @header.abouts_title
    fill_in "Blogs sub title", with: @header.blogs_sub_title
    fill_in "Blogs title", with: @header.blogs_title
    fill_in "Boards sub title", with: @header.boards_sub_title
    fill_in "Boards title", with: @header.boards_title
    fill_in "Cta1", with: @header.cta1
    fill_in "Cta2", with: @header.cta2
    fill_in "Features sub title", with: @header.features_sub_title
    fill_in "Features title", with: @header.features_title
    fill_in "Feedbacks sub title", with: @header.feedbacks_sub_title
    fill_in "Feedbacks title", with: @header.feedbacks_title
    fill_in "Headerimg", with: @header.headerimg
    fill_in "Products sub title", with: @header.products_sub_title
    fill_in "Products title", with: @header.products_title
    fill_in "Services sub title", with: @header.services_sub_title
    fill_in "Services title", with: @header.services_title
    click_on "Update Header"

    assert_text "Header was successfully updated"
    click_on "Back"
  end

  test "should destroy Header" do
    visit header_url(@header)
    click_on "Destroy this header", match: :first

    assert_text "Header was successfully destroyed"
  end
end
