require "application_system_test_case"

class PriceHistoriesTest < ApplicationSystemTestCase
  setup do
    @price_history = price_histories(:one)
  end

  test "visiting the index" do
    visit price_histories_url
    assert_selector "h1", text: "Price histories"
  end

  test "should create price history" do
    visit price_histories_url
    click_on "New price history"

    fill_in "Datte", with: @price_history.datte
    fill_in "Price", with: @price_history.price
    fill_in "Product", with: @price_history.product_id
    click_on "Create Price history"

    assert_text "Price history was successfully created"
    click_on "Back"
  end

  test "should update Price history" do
    visit price_history_url(@price_history)
    click_on "Edit this price history", match: :first

    fill_in "Datte", with: @price_history.datte
    fill_in "Price", with: @price_history.price
    fill_in "Product", with: @price_history.product_id
    click_on "Update Price history"

    assert_text "Price history was successfully updated"
    click_on "Back"
  end

  test "should destroy Price history" do
    visit price_history_url(@price_history)
    click_on "Destroy this price history", match: :first

    assert_text "Price history was successfully destroyed"
  end
end
