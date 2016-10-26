class JwtAuth

  def initialize app
    @app = app
    @jwt_issuer = 'zoral.com'
    @jwt_secret = 'keepitsecret'
  end

  def call env
    begin
      options = {algorithm: 'HS256', iss: @jwt_issuer}
      bearer = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
      payload, header = JWT.decode bearer, @jwt_secret, true, options

      env[:scopes] = payload['scopes']
      env[:customer] = payload['customer']

      @app.call env
    rescue JWT::DecodeError
      [401, {'Content-Type' => 'text/plain'}, ['A token must be passed.']]
    rescue JWT::ExpiredSignature
      [403, {'Content-Type' => 'text/plain'}, ['The token has expired.']]
    rescue JWT::InvalidIssuerError
      [403, {'Content-Type' => 'text/plain'}, ['The token does not have a valid issuer.']]
    rescue JWT::InvalidIatError
      [403, {'Content-Type' => 'text/plain'}, ['The token does not have a valid "issued at" time.']]
    end
  end

end

class Customer < Sinatra::Base
  use JwtAuth

  def initialize
    super

    @accounts = {
        tomdelonge: 10000,
        markhoppus: 50000,
        travisbarker: 1000000000
    }
  end

  configure do
    set :customerBackEnd, TurboCassandra::CustomerBackEnd.new
    set :orderBackEnd, TurboCassandra::OrderBackEnd.new
    set :groupPriceBackEnd, TurboCassandra::GroupPriceBackEnd.new
  end

  before do
    content_type :json
  end

  get '/test' do
    scopes, customer = request.env.values_at :scopes, :customer
    customer_name = customer

    if scopes.include?('view_prices')
      {money: customer_name}.to_json
    else
      halt 403
    end
  end
  get '/account' do
    scopes, customer = request.env.values_at :scopes, :customer

    if scopes.include?('view_prices')
      settings.customerBackEnd.get_customer_info customer['id']
    else
      halt 403
    end
  end

  get '/order' do
    scopes, customer = request.env.values_at :scopes, :customer

    if scopes.include?('view_prices')
      settings.orderBackEnd.get_order_by_customer_id(customer['id'].to_s)
    else
      halt 403
    end
  end

  get '/product/:id/price' do
    customer = request.env.values_at :customer
    sku = params[:id].to_i
    price = settings.groupPriceBackEnd.get_price(sku,  'W')
    {price: price}.to_json

  end

end
