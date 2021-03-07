#!/usr/bin/env ruby

require 'yaml'

# function to open and read in file
def read_file(f)
  file = File.open(f, 'r')
  data = file.read
  file.close
  data
end

# load website config file
site_config = YAML.safe_load(read_file('site.yml'))

# data for GitHub buttons
buttons = [
  ['', "Follow @#{site_config['github_username']} on GitHub", "Follow @#{site_config['github_username']}", ''],
  ["/#{site_config['repository']}", "Star #{site_config['github_username']}/#{site_config['repository']} on GitHub", 'Star', 'star'],
  ["/#{site_config['repository']}/subscription", "Watch #{site_config['github_username']}/#{site_config['repository']} on GitHub", 'Watch', 'eye'],
  ["/#{site_config['repository']}/fork", "Fork #{site_config['github_username']}/#{site_config['repository']} on GitHub", 'Fork', 'repo-forked']
]

# function to make the list of GitHub buttons
def add_github_buttons(arr)
  s = ''
  arr.map do |button|
    s += %(
          <li>
            <a class="github-button" href="https://github.com/jbampton#{button[0]}")
    s += %( data-icon="octicon-#{button[3]}" ) unless button[3] == ''
    s += %( data-size="large" data-show-count="true" aria-label="#{button[1]}">#{button[2]}</a>
          </li>)
  end
  s
end

# function
def ii(i)
  i.positive? ? i : ''
end

# function that generates the pie chart data
def generate_data
  tokens = []
  # loop over schema files
  Dir.glob('schema/*.xsd').map do |schema|
    data = read_file(schema)
    data.scan(/<xs:\w+|\w+="\w+"|\w+="xs:\w+"/).uniq do |x|
      tokens << x unless tokens.include? x
    end
    data.scan(/<xs:\w+ \w+="\w+"/).uniq do |x|
      tokens << x unless tokens.include? x
    end
  end
  # create main data array
  structure = []
  tokens.sort.map.with_index do |x, i|
    structure[i] = [x]
    Dir.glob('schema/*.xsd').map do |schema|
      filename = schema.split('/').last
      data = read_file(schema)
      filename = filename.split('.').first
      structure[i] << [filename, data.scan(x).size]
    end
  end
  structure
end

# common function that prints the chart title
def chart_title(chart_type, ind)
  "#{ind + 1} - Branch gh-pages count of: #{chart_type} grouped by file"
end

# common function to escape double quotes
def escape(s)
  s.gsub('"', '\"')
end

# common function for each chart
def draw_chart(which_chart, data, chart_string, chart_values, chart_title, chart_div, width, height)
  %(
        function drawChart#{which_chart}() {
          // Create the data table.
          var data = new google.visualization.DataTable();
          data.addColumn("string", "#{escape(chart_string)}");
          data.addColumn("number", "#{chart_values}");
          data.addRows(#{data});
          // Set chart options
          var options = {"title": "#{escape(chart_title)}",
                         is3D: true,
                         "pieSliceText": "value",
                         "width": #{width},
                         "height": #{height},
                         "titleTextStyle": {"color": "black"}};
          // Instantiate and draw our chart, passing in some options.
          var chart = new google.visualization.PieChart(document.getElementById("chart_div_#{chart_div}"));
          chart.draw(data, options);
        }\n)
end

# build all the website pages
def page_build(page_count)
  (0..page_count).map do |i|
    instance_variable_set("@page#{ii i}", instance_variable_get("@page#{ii i}") + $page)
  end
end

# add navigation hyperlinks
def add_links(page_count)
  page = ''
  (0..page_count).map do |i|
    page += %(
            <li><a href="index#{ii i}.html">Page #{i + 1}</a></li>)
  end
  page
end

# remove special characters as they clash with JavaScript's naming conventions
def clean_chart(chart)
  chart.tr('<"=: ', '')
end
# chart size variables
width = 400
height = 330
# data variable
structure = generate_data
# start common page region
$page = %(<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head;
         any other head content must come *after* these tags -->
    <title>#{site_config['title']}</title>
    <meta name="theme-color" content="##{site_config['theme_color']}">
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">
    <!-- Optional theme -->
    <link rel="stylesheet" href="bootstrap/css/bootstrap-theme.min.css">
    <style>
      .container-fluid { padding: 0px; }
      .navbar, .navbar-default { padding: 5pt; background-color: ##{site_config['theme_color']} !important; font-size: 13pt; }
      .navbar, .navbar-default li a { color: #000 !important; }
      .navbar-default .navbar-brand { font-size: 15pt; font-weight: bold; }
      .navbar-default li:hover a, .navbar-default .navbar-brand:hover { background-color: #{site_config['nav_hover_color']} !important; }
      div[id^="chart_div"] > div > div { margin: auto; }
      footer { background-color: ##{site_config['theme_color']}; min-height: 200px; }
      footer ul a { color: #fff !important; }
      .selected { background-color: #{site_config['nav_selected_color']}; font-weight: bold; }
      .nuchecker a { font-weight: bold; }
    </style>
  </head>
  <body>
    <!-- Static navbar -->
    <nav class="navbar navbar-default">
      <div class="container-fluid">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="index.html" id="head1">#{site_config['nav_heading']}</a>
        </div>
        <div id="navbar" class="navbar-collapse collapse">
          <ul class="nav navbar-nav">)
# try 50 charts per page
page_count = structure.size / 50
(0..page_count).map do |i|
  instance_variable_set("@page#{ii i}", $page)
end
# restart common page region
$page = add_links(page_count)
# continue to build all the pages
page_build(page_count)
# restart common page region
$page = '
          </ul>
        </div>
      </div>
    </nav>
    <div class="container-fluid">'
# continue to build all the pages
page_build(page_count)
# add chart divs to each page
structure.map.with_index do |chart, i|
  data0 = clean_chart(chart[0])
  i /= 50
  instance_variable_set("@page#{ii i}", instance_variable_get("@page#{ii i}") + "\n       <div class=\"col-sm-6 col-md-4 col-lg-3\" id=\"chart_div_#{data0}\"></div>")
end
# restart common page region
$page = '
    </div>
    <footer>
      <div class="container">
        <ul class="list-unstyled">'
$page += add_github_buttons(buttons)
# continue to build all the pages
page_build(page_count)
# restart common page region
$page = add_links(page_count)
# continue to build all the pages
page_build(page_count)
# restart common page region
$page = %(
            <li><a href="#head1">#{site_config['back_to_top']}</a></li>
            <li class="nuchecker">
              <a href="#" rel="noopener">#{site_config['valid_html']}</a>
            </li>
        </ul>
        <a href="http://s05.flagcounter.com/more/BHT"
           target="_blank" rel="noopener">
          <img src="http://s05.flagcounter.com/count2/BHT/bg_FFFFFF/txt_000000/border_CCCCCC/columns_3/maxflags_250/viewers_0/labels_1/pageviews_1/flags_0/percent_0/"
               alt="Flag Counter">
        </a>
      </div>
    </footer>)
# add all the websites external JavaScript files
site_scripts = %w[https://www.gstatic.com/charts/loader.js https://www.google.com/jsapi bootstrap/js/jquery.min.js bootstrap/js/bootstrap.min.js]
site_scripts.map do |script|
  $page += %(
    <script src="#{script}"></script>)
end

$page += %(
    <script>
      // Load the Visualization API and the corechart package.
      google.charts.load("current", {"packages":["corechart"]});\n)
# continue to build all the pages
page_build(page_count)
# add all the javascript for each pie chart to each page
structure.map.with_index do |chart, ind|
  data0 = clean_chart(chart[0])
  data1 = chart[1..-1]
  v = 'Values'
  i = ind / 50
  instance_variable_set("@page#{ii i}", instance_variable_get("@page#{ii i}") + "        google.charts.setOnLoadCallback(drawChart#{data0});\n" + draw_chart(data0, data1, chart[0], v, chart_title(chart[0], ind), data0, width, height))
end
# restart common page region
$page = '
      $(document).ready(function () {
         "use strict";
         var last = $(location).attr("href").split("/").pop().split(".")[0].replace(/index/, "");
         var tab = 1;
         if (last !== "") {
           tab = parseInt(last) + 1;
         }
         $(".navbar-nav li:nth-child(" + tab + ")").addClass("selected");
         tab--;
         if (tab === 0) {
           tab = "";
         }
         $(".nuchecker a").attr("href", "https://validator.w3.org/nu/?doc=http%3A%2F%2Fslurpcode.github.io%2Fdashboard-2%2Findex" + tab + ".html");
      });
    </script>
    <script async defer src="https://buttons.github.io/buttons.js"></script>
  </body>
</html>'
# finish building all the pages
page_build(page_count)
# write all the HTML pages to files
(0..page_count).map do |i|
  file = File.open("index#{ii i}.html", 'w')
  file.write(instance_variable_get("@page#{ii i}"))
  file.close
end
