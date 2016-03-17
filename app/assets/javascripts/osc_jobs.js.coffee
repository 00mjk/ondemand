# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@update_display = (id) ->
  request_job_data(id)
  update_copy_button(id)
  update_template_button(id)
  update_destroy_button(id)
  show_job_panel(id)

@request_job_data = (id) ->
  if id?
    $.ajax
      type: 'GET'
      url: '.' + Routes.osc_job_path(id)
      contentType: "application/json; charset=utf-8"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log jqXHR
      success: (data, textStatus, jqXHR) ->
        # TODO add display method
        console.log data

@update_copy_button = (id) ->
  if id?
    $("#copy_button").attr('href', '.' + Routes.copy_osc_job_path(id))
    $("#copy_button").data("method", "PUT")
    $("#copy_button").removeAttr("disabled")
  else
    $("#copy_button").attr("href", "#")
    $("#copy_button").data("method", "GET")
    $("#copy_button").attr("disabled", true)

@show_job_panel = (id) ->
  if id?
    $("#jobDetailsPanel").fadeIn(200)
  else
    $("#jobDetailsPanel").fadeOut(200)


@update_stop_button = (running) ->
  if running?
    # TODO Create a route that will stop a running job.
    $("#stop_button").attr("href", ' TODO ')
    $("#stop_button").removeAttr("disabled")
  else
    $("#stop_button").removeAttr("href")
    $("#stop_button").attr("disabled", true)

@update_template_button = (id) ->
  if id?
    $("#template_button").attr("href", ' TODO ')
    $("#template_button").removeAttr("disabled")
  else
    $("#template_button").removeAttr("href")
    $("#template_button").attr("disabled", true)

@update_destroy_button = (id) ->
  if id?
    $("#destroy_button").attr("href", ' TODO ')
    $("#destroy_button").removeAttr("disabled")
  else
    $("#destroy_button").removeAttr("href")
    $("#destroy_button").attr("disabled", true)

