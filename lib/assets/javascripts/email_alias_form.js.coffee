# Copyright 2014 Square Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

root = exports ? this

# A form, list, and associated help text for viewing, adding, and deleting email
# aliases. Used by the `account/edit` and `project/membership/edit` views.

class root.EmailAliasForm

  # Constructs a new email alias form.
  #
  # @param [jQuery element array] element The DOM element to construct the
  #   form in.
  # @param [String] filterEndpoint The URL endpoint for filtering emails.
  # @param [String] createEndpoint The URL endpoint for adding new emails.
  constructor: (@element, @filterEndpoint, @createEndpoint) ->
    this.buildList()
    this.buildForm()
    this.processResults()

  # @private
  processResults: (query) ->
    query ||= @filter.val()
    $.ajax "#{@filterEndpoint}?query=#{encodeURIComponent query}",
      type: 'GET'
      success: (results) =>
        @results.find('li').remove()
        for email in results
          do (email) =>
            li = $('<li/>').text(email.email + ' ').appendTo(@results)
            if email.source then $('<span/>').addClass('aux').text("(#{email.source.name}) ").appendTo(li)
            button = $('<button/>').addClass('warning small').text("Remove").appendTo(li)
            button.click =>
              button.attr 'disabled', 'disabled'
              $.ajax email.url,
                type: 'DELETE'
                complete: => this.processResults()
                error: -> new Flash('alert').text("Couldn’t remove that email address.")
      error: -> new Flash('alert').text("Error retrieving search results.")

  # @private
  buildList: ->
    @filter = $('<input/>').attr({type: 'search', placeholder: 'Find an email'}).appendTo(@element)
    @results = $('<ul/>').addClass('email-search-results').appendTo(@element)
    new DynamicSearchField @filter, (query) => @processResults(query)

  # @private
  buildForm: ->
    @form = $('<form/>').
      attr({action: @createEndpoint, method: 'POST'}).
      addClass('labeled').
      appendTo(@element)
    $('<label/>').attr('for', 'email[email]').text('Add another email address: ').appendTo(@form)
    group = $('<div/>').addClass('field-group').appendTo(@form)
    $('<input/>').attr({type: 'email', name: 'email[email]'}).appendTo group
    $('<input/>').attr({type: 'submit', value: "Add"}).addClass('default').appendTo group

    new SmartForm @form, (email) =>
      @form.find('input[type!=submit]').val ''
      this.processResults()
