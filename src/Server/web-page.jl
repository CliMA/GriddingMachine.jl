#=
The query page.

The tag list is injected on every request, not at include time: `YAML_TAGS` is empty until
`Collector.load_database!` runs, so a template built at load time would always ship an empty
selector.
=#

"""Placeholder replaced with `<option>` elements for every catalog tag."""
const TAG_OPTIONS_PLACEHOLDER = "{{TAG_OPTIONS}}"

const PAGE_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>GriddingMachine query</title>
<style>
  body { font-family: system-ui, sans-serif; margin: 0; padding: 1.5rem; background: #f6f7f9; color: #1c1e21; }
  h1 { font-size: 1.25rem; margin: 0 0 1rem; }
  .note { background: #fff6e5; border-left: 3px solid #e8a33d; padding: .6rem .8rem; font-size: .85rem; margin-bottom: 1rem; }
  .tabs { display: flex; gap: .4rem; margin-bottom: -1px; }
  .tabs button { border: 1px solid #ccd0d5; border-bottom: none; background: #e9ebee; padding: .5rem .9rem; cursor: pointer; font-size: .9rem; }
  .tabs button.active { background: #fff; font-weight: 600; }
  .panel { display: none; background: #fff; border: 1px solid #ccd0d5; padding: 1rem; }
  .panel.active { display: block; }
  .field { display: flex; align-items: center; gap: .5rem; margin-bottom: .6rem; }
  .field label { width: 11rem; font-size: .85rem; }
  .field input, .field select { padding: .3rem .4rem; font-size: .9rem; min-width: 15rem; }
  button.run { margin-top: .4rem; padding: .45rem 1.1rem; font-size: .9rem; cursor: pointer; }
  #status { margin: 1rem 0 .4rem; font-size: .9rem; }
  #status.error { color: #b3261e; }
  pre { background: #1c1e21; color: #e6e6e6; padding: .8rem; overflow: auto; max-height: 26rem; font-size: .8rem; }
  .toggle { font-size: .85rem; margin-bottom: .4rem; display: block; }
</style>
</head>
<body>
<h1>GriddingMachine query</h1>

<div class="note">
  This page is meant for a local or trusted intranet network. There is no access control:
  the <code>user</code> field is a label written to the server log, not a credential.
  The land parameter query downloads whole datasets on first use and can take several minutes.
</div>

<div class="tabs">
  <button data-panel="panel-sitedata" class="active">Site data</button>
  <button data-panel="panel-gmdict">Land parameters</button>
  <button data-panel="panel-weather">Weather drivers</button>
</div>

<div id="panel-sitedata" class="panel active" data-endpoint="/sitedata.json">
  <div class="field"><label for="sd-tag">Dataset tag</label>
    <input id="sd-tag" name="tag" list="gm-tags" placeholder="type to filter, e.g. ELEV"></div>
  <div class="field"><label for="sd-lat">Latitude</label>
    <input id="sd-lat" name="lat" type="number" step="any" value="40.03"></div>
  <div class="field"><label for="sd-lon">Longitude</label>
    <input id="sd-lon" name="lon" type="number" step="any" value="-105.55"></div>
  <div class="field"><label for="sd-cycle">Cycle (0 = all)</label>
    <input id="sd-cycle" name="cycle" type="number" step="1" value="0"></div>
  <div class="field"><label for="sd-std">Include error variable</label>
    <input id="sd-std" name="include_std" type="checkbox" checked></div>
  <div class="field"><label for="sd-user">User label</label>
    <input id="sd-user" name="user" value="anonymous"></div>
  <button class="run">Query</button>
</div>

<div id="panel-gmdict" class="panel" data-endpoint="/gmdict.json">
  <div class="field"><label for="gd-version">Collection</label>
    <select id="gd-version" name="gmversion">
      <option value="gm1">gm1</option>
      <option value="gm2" selected>gm2</option>
    </select></div>
  <div class="field"><label for="gd-year">Year</label>
    <input id="gd-year" name="year" type="number" step="1" value="2020"></div>
  <div class="field"><label for="gd-lat">Latitude</label>
    <input id="gd-lat" name="lat" type="number" step="any" value="40.03"></div>
  <div class="field"><label for="gd-lon">Longitude</label>
    <input id="gd-lon" name="lon" type="number" step="any" value="-105.55"></div>
  <div class="field"><label for="gd-user">User label</label>
    <input id="gd-user" name="user" value="anonymous"></div>
  <button class="run">Query</button>
</div>

<div id="panel-weather" class="panel" data-endpoint="/weather.json">
  <div class="field"><label for="wd-version">Collection</label>
    <select id="wd-version" name="wdversion">
      <option value="wd1" selected>wd1</option>
    </select></div>
  <div class="field"><label for="wd-year">Year</label>
    <input id="wd-year" name="year" type="number" step="1" value="2020"></div>
  <div class="field"><label for="wd-lat">Latitude</label>
    <input id="wd-lat" name="lat" type="number" step="any" value="40.03"></div>
  <div class="field"><label for="wd-lon">Longitude</label>
    <input id="wd-lon" name="lon" type="number" step="any" value="-105.55"></div>
  <div class="field"><label for="wd-user">User label</label>
    <input id="wd-user" name="user" value="anonymous"></div>
  <button class="run">Query</button>
</div>

<datalist id="gm-tags">
$(TAG_OPTIONS_PLACEHOLDER)
</datalist>

<div id="status"></div>
<label class="toggle"><input id="expand" type="checkbox"> Expand full arrays</label>
<pre id="result">No query yet.</pre>

<script>
var ABBREVIATE_ABOVE = 12;
var lastPayload = null;

function activate(panelId) {
  var buttons = document.querySelectorAll('.tabs button');
  for (var i = 0; i < buttons.length; i++) {
    buttons[i].classList.toggle('active', buttons[i].dataset.panel === panelId);
  }
  var panels = document.querySelectorAll('.panel');
  for (var j = 0; j < panels.length; j++) {
    panels[j].classList.toggle('active', panels[j].id === panelId);
  }
}

function abbreviate(value) {
  if (Array.isArray(value)) {
    if (value.length > ABBREVIATE_ABOVE) {
      return '[' + value.slice(0, 3).join(', ') + ', ...] (' + value.length + ' values)';
    }
    return value;
  }
  if (value && typeof value === 'object') {
    var reduced = {};
    for (var key in value) { reduced[key] = abbreviate(value[key]); }
    return reduced;
  }
  return value;
}

function render() {
  if (lastPayload === null) { return; }
  var expand = document.getElementById('expand').checked;
  var shown = expand ? lastPayload : abbreviate(lastPayload);
  document.getElementById('result').textContent = JSON.stringify(shown, null, 2);
}

function run(panel) {
  var status = document.getElementById('status');
  status.className = '';
  status.textContent = 'Requesting... the first land parameter query downloads datasets and may take several minutes.';

  var query = [];
  var inputs = panel.querySelectorAll('input[name], select[name]');
  for (var i = 0; i < inputs.length; i++) {
    var field = inputs[i];
    var value = field.type === 'checkbox' ? (field.checked ? 'true' : 'false') : field.value;
    query.push(encodeURIComponent(field.name) + '=' + encodeURIComponent(value));
  }

  var started = Date.now();
  fetch(panel.dataset.endpoint + '?' + query.join('&'))
    .then(function (response) { return response.json(); })
    .then(function (payload) {
      var elapsed = ((Date.now() - started) / 1000).toFixed(2);
      lastPayload = payload;
      if (payload.Warning) {
        status.className = 'error';
        status.textContent = payload.Warning +
          (payload.Reason ? ' (' + payload.Reason + ')' : '') + ' - ' + elapsed + ' s';
      } else {
        status.textContent = 'Done in ' + elapsed + ' s';
      }
      render();
    })
    .catch(function (error) {
      status.className = 'error';
      status.textContent = 'Request failed: ' + error;
    });
}

document.addEventListener('click', function (event) {
  if (event.target.matches('.tabs button')) { activate(event.target.dataset.panel); }
  if (event.target.matches('button.run')) { run(event.target.closest('.panel')); }
});
document.getElementById('expand').addEventListener('change', render);
</script>
</body>
</html>
"""

"""

    query_page()

Return the query page with one `<option>` per catalog tag.

The options are built on every call so that tags registered after module load are visible.
"""
function query_page()
    options = join(["  <option value=\"$(tag)\"></option>" for tag in sort(YAML_TAGS)], "\n")
    return replace(PAGE_TEMPLATE, TAG_OPTIONS_PLACEHOLDER => options)
end;
