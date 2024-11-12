class NotificationMailer < ApplicationMailer
  def discount_email
      @user = params[:user]
      @product = params[:product]
      @discount_percentage = params[:discount_percentage]
       mail(
        to: @user.email,
        subject: "¡Descuento en #{@product.name} del #{@discount_percentage}%!"
      )
  end
end
