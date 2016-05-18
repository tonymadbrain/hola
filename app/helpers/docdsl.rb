# some meta data for documentation page (optional)
page do
  title "Hola API docs"
  introduction "REST API for simple taskmanager Hola.

Resources /users, /tasks, /users/:id, /tasks/:id, /users/:id/tasks provide header Link

Meaning of used HTTP status & error codes:

* 200 OK - Success!
* 201 Created - Success!
* 202 Accepted - Success!
* 400 Bad Request - The request was invalid or cannot be otherwise served. An
  accompanying error message will explain further.
* 404 Not Found - The URI requested is invalid or the resource
  requested, such as a user, does not exists.
* 405 Method Not Allowed - Just nope!
*
  "
  footer "[Github](https://github.com/tonymadbrain/hola_api)"
  configure_renderer do
    self.render_md
  end
end
