m = require 'mithril'
_ = require 'lodash'

class Issue
  constructor: ->
    for property in @properties
      this[property] = m.prop null

  properties:
    ['owner', 'repository', 'title', 'body', 'milestone', 'labels', 'assignee']

  prop4queries: ->
    _.filter @properties, (e)->
      switch e
        when 'owner', 'repository' then false
        else true

  url: ->
    url = 'https://github.com/'

    repos = [@owner(), @repository(), 'issues', 'new'].join('/') if @owner() and @owner().length > 0 and @repository() and @repository().length > 0

    query = []
    self = this
    for prop in @prop4queries()
      if self[prop]() and self[prop]().length > 0
        switch prop
          when 'labels'
            self[prop]().split(",").forEach (e)->
              query.push "#{prop}[]=" + encodeURIComponent(e)
          else
            query.push "#{prop}=" + encodeURIComponent(self[prop]())

    if repos and query.length > 0
      url + repos + '?' + query.join('&')
    else
      url

App =
  controller: ->
    issue: new Issue()
  view: (ctrl)->
    props = ctrl.issue.properties.map (e)->
      if e == 'body'
        <tr>
          <th>{_.capitalize e}</th><td><textarea onkeyup={m.withAttr("value", ctrl.issue[e])} value={ctrl.issue[e]()} /></td>
        </tr>
      else
        <tr>
          <th>{_.capitalize e}</th><td><input type="text" onkeyup={m.withAttr("value", ctrl.issue[e])} value={ctrl.issue[e]()}  /></td>
        </tr>

    <div>
      <div class="ui card centered">
        <div class="content">
          <div class="header">GitHub Issue Link here</div>
          <p><a href={ctrl.issue.url()} target="github">{ctrl.issue.url()}</a></p>
          <p>Owner and Repository are REQUIRED. Labels accepts CSV.</p>
        </div>
        <div class="extra right aligned"><a href={ctrl.issue.url()} target="github">Go to GitHub</a></div>
      </div>

      <div class="ui form">
      <table>
        <tbody>
          <tr>
            <td colspan="2">Input here.</td>
          </tr>
        {props}
        </tbody>
      </table>
      </div>
      <div class="ui hidden divider"></div>
      <p class="ui centered grid"><a class="ui button orange" href={ctrl.issue.url()} target="github">GitHub <i class="icon external"></i></a></p>
    </div>

m.mount document.getElementById('root'), App
