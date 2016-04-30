def json_error(msg="Internal Server Error", status=500)
  Rack::Response.new(
    [{'error': {'status': status, 'message': msg}}.to_json],
    status,
    {'Content-type' => 'application/json'}
  ).finish
end

# Returns a hash that includes everything but the given keys.
#   hash = { a: true, b: false, c: nil}
#   hash.except(:c) # => { a: true, b: false}
#   hash # => { a: true, b: false, c: nil}
#
# This is useful for limiting a set of parameters to everything but a few known toggles:
#   @person.update(params[:person].except(:admin))
def except(*keys)
  dup.except!(*keys)
end

# Replaces the hash without the given keys.
#   hash = { a: true, b: false, c: nil}
#   hash.except!(:c) # => { a: true, b: false}
#   hash # => { a: true, b: false }
def except!(*keys)
  keys.each { |key| delete(key) }
  self
end

# def current_user
#   User.find(@params[:user])
# end
