require "test_helper"

class PriceHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @price_history = price_histories(:one)
  end

  test "should get index" do
    get price_histories_url
    assert_response :success
  end

  test "should get new" do
    get new_price_history_url
    assert_response :success
  end

  test "should create price_history" do
    assert_difference("PriceHistory.count") do
      post price_histories_url, params: { price_history: { datte: @price_history.datte, price: @price_history.price, product_id: @price_history.product_id } }
    end

    assert_redirected_to price_history_url(PriceHistory.last)
  end

  test "should show price_history" do
    get price_history_url(@price_history)
    assert_response :success
  end

  test "should get edit" do
    get edit_price_history_url(@price_history)
    assert_response :success
  end

  test "should update price_history" do
    patch price_history_url(@price_history), params: { price_history: { datte: @price_history.datte, price: @price_history.price, product_id: @price_history.product_id } }
    assert_redirected_to price_history_url(@price_history)
  end

  test "should destroy price_history" do
    assert_difference("PriceHistory.count", -1) do
      delete price_history_url(@price_history)
    end

    assert_redirected_to price_histories_url
  end
end
