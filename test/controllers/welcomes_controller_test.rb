require "test_helper"

class WelcomesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @welcome = welcomes(:one)
  end

  test "should get index" do
    get welcomes_url
    assert_response :success
  end

  test "should get new" do
    get new_welcome_url
    assert_response :success
  end

  test "should create welcome" do
    assert_difference("Welcome.count") do
      post welcomes_url, params: { welcome: { address: @welcome.address, desc: @welcome.desc, email: @welcome.email, footer: @welcome.footer, ig: @welcome.ig, link: @welcome.link, ln: @welcome.ln, logoimg: @welcome.logoimg, phone: @welcome.phone, section: @welcome.section, telegram: @welcome.telegram, title: @welcome.title, twitter: @welcome.twitter, whatsapp: @welcome.whatsapp, youtube: @welcome.youtube } }
    end

    assert_redirected_to welcome_url(Welcome.last)
  end

  test "should show welcome" do
    get welcome_url(@welcome)
    assert_response :success
  end

  test "should get edit" do
    get edit_welcome_url(@welcome)
    assert_response :success
  end

  test "should update welcome" do
    patch welcome_url(@welcome), params: { welcome: { address: @welcome.address, desc: @welcome.desc, email: @welcome.email, footer: @welcome.footer, ig: @welcome.ig, link: @welcome.link, ln: @welcome.ln, logoimg: @welcome.logoimg, phone: @welcome.phone, section: @welcome.section, telegram: @welcome.telegram, title: @welcome.title, twitter: @welcome.twitter, whatsapp: @welcome.whatsapp, youtube: @welcome.youtube } }
    assert_redirected_to welcome_url(@welcome)
  end

  test "should destroy welcome" do
    assert_difference("Welcome.count", -1) do
      delete welcome_url(@welcome)
    end

    assert_redirected_to welcomes_url
  end
end
