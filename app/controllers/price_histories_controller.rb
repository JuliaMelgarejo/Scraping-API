class PriceHistoriesController < ApplicationController
  before_action :set_price_history, only: %i[show edit update destroy]

  # GET /price_histories or /price_histories.json
  def index
    @price_histories = PriceHistory.all
  end

  # GET /price_histories/1 or /price_histories/1.json
  def show
  end

  # GET /price_histories/new
  def new
    @price_history = PriceHistory.new
  end

  # GET /price_histories/1/edit
  def edit
  end

  # POST /price_histories or /price_histories.json
  def create
    @price_history = PriceHistory.new(price_history_params)

    respond_to do |format|
      if @price_history.save
        format.html { redirect_to @price_history, notice: "Price history was successfully created." }
        format.json { render :show, status: :created, location: @price_history }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @price_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /price_histories/1 or /price_histories/1.json
  def update
    respond_to do |format|
      if @price_history.update(price_history_params)
        format.html { redirect_to @price_history, notice: "Price history was successfully updated." }
        format.json { render :show, status: :ok, location: @price_history }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @price_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /price_histories/1 or /price_histories/1.json
  def destroy
    @price_history.destroy

    respond_to do |format|
      format.html { redirect_to price_histories_path, status: :see_other, notice: "Price history was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    def set_price_history
      @price_history = PriceHistory.find(params[:id])
    end

    def price_history_params
      params.require(:price_history).permit(:date, :price, :product_id)
    end
end
