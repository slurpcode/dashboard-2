# function that generates the pie chart data
def generate_data
  tokens = []
  # loop over schema files
  Dir.glob('schema/*.xsd').map do |schema|
    file = File.open(schema, 'r')
    data = file.read
    file.close
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
      file = File.open(schema, 'r')
      data = file.read
      file.close
      structure[i] << [filename, data.scan(x).size]
    end
  end
  structure
end
# common function that prints the chart title
def chart_title(charttype, ind)
  "#{ind + 1} - Branch gh-pages count of: #{charttype} grouped by file"
end
# common function for each chart
def draw_chart(whichChart, data, chartstring, chartnumber, charttitle, chartdiv, width, height)
      "
        function drawChart#{whichChart}() {
          // Create the data table.
          var data = new google.visualization.DataTable();
          data.addColumn('string', '#{chartstring}');
          data.addColumn('number', '#{chartnumber}');
          data.addRows(#{data});
          // Set chart options
          var options = {'title': '#{charttitle}',
                         is3D: true,
                         'width': #{width},
                         'height': #{height},
                         'titleTextStyle': { 'color': 'black' } };
          // Instantiate and draw our chart, passing in some options.
          var chart = new google.visualization.PieChart(document.getElementById('chart_div_#{chartdiv}'));
          chart.draw(data, options);
        }\n"
end
# buld all the website pages
def page_build(pagecount)
  (0..pagecount).map do |i|
    instance_variable_set("@page#{i > 0 ? i : ''}", instance_variable_get("@page#{i > 0 ? i : ''}") + $page)
  end
end
# add navigation hyperlinks
def add_links(pagecount, page)
  (0..pagecount).map do |i|
    page += "
            <li><a href='index#{i > 0 ? i : ''}.html'>Page #{i + 1}</a></li>"
  end
  page
end
# chart size variables
width = 400
height = 330
# data variable
structure = generate_data
# start common page region
$page = <<-EOS
<!DOCTYPE html>
<html lang='en'>
  <head>
    <meta charset='UTF-8'>
    <meta http-equiv='X-UA-Compatible' content='IE=edge'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>Analytics Dashboard</title>
    <!-- Latest compiled and minified CSS -->
    <link rel='stylesheet' href='bootstrap/css/bootstrap.min.css'>
    <!-- Optional theme -->
    <link rel='stylesheet' href='bootstrap/css/bootstrap-theme.min.css'>
    <style>
      .container-fluid { padding: 0px; }
      .navbar, .navbar-default { padding: 5pt; background-color: rgba(49,37,152,0.8) !important; font-size: 12pt; }
      .navbar, .navbar-default li a { color: #000 !important; }
      .navbar-default .navbar-brand, .navbar-default .navbar-brand:hover { color: #fff; font-size: 15pt; }
      div[id^="chart_div"] > div > div { margin: auto; }
      footer { background-color: rgba(49,37,152,0.8); min-height: 200px; color: #fff !important; }
      footer ul a { color: #fff !important; }
      .selected { background-color: aliceblue; font-weight: bold; }
      .navbar-default li:hover a { background-color: red !important; }
      .nuchecker a { font-weight: bold; }
    </style>
  </head>
  <body>
    <!-- Static navbar -->
    <nav class='navbar navbar-default'>
      <div class='container-fluid'>
        <div class='navbar-header'>
          <button type='button' class='navbar-toggle collapsed' data-toggle='collapse' data-target='#navbar' aria-expanded='false' aria-controls='navbar'>
            <span class='sr-only'>Toggle navigation</span>
            <span class='icon-bar'></span>
            <span class='icon-bar'></span>
            <span class='icon-bar'></span>
          </button>
          <a class='navbar-brand' href='index.html' id='head1'>Analytics Dashboard</a>
        </div>
        <div id='navbar' class='navbar-collapse collapse'>
          <ul class='nav navbar-nav'>
EOS
# try 50 charts per page
pagecount = structure.size / 50
(0..pagecount).map do |i|
  instance_variable_set("@page#{i > 0 ? i : ''}", $page)
end
# restart common page region
$page = add_links(pagecount, '')
# continue to build all the pages
page_build(pagecount)
# restart common page region
$page = "
          </ul>
        </div>
      </div>
    </nav>
    <div class='container-fluid'>"
# continue to build all the pages
page_build(pagecount)
# add chart divs to each page
structure.map.with_index do |chart, i|
  data0 = chart[0].tr('<"=: ', '')
  i = i / 50
  instance_variable_set("@page#{i > 0 ? i : ''}", instance_variable_get("@page#{i > 0 ? i : ''}") + "\n       <div class='col-sm-6 col-md-4 col-lg-3' id='chart_div_#{data0}'></div>")
end
# restart common page region
$page = "
    </div>
    <footer>
      <div class='container'>
        <ul class='list-unstyled'>
            <li><a href='#head1'>Back to top</a></li>"
# continue to build all the pages
page_build(pagecount)
#restart common page region
$page = add_links(pagecount, '')
# continue to build all the pages
page_build(pagecount)
# restart common page region
$page = "
            <li class='nuchecker'><a target='_blank'>Valid HTML</a>
        </ul>
        <a href='http://s05.flagcounter.com/more/BHT'><img src='http://s05.flagcounter.com/count2/BHT/bg_FFFFFF/txt_000000/border_CCCCCC/columns_3/maxflags_250/viewers_0/labels_1/pageviews_1/flags_0/percent_0/' alt='Flag Counter'></a>
      </div>
    </footer>
    <!--Load the AJAX API-->
    <script src='https://www.gstatic.com/charts/loader.js'></script>
    <script src='https://www.google.com/jsapi'></script>
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src='bootstrap/js/jquery.min.js'></script>
    <!-- Latest compiled and minified JavaScript -->
    <script src='bootstrap/js/bootstrap.min.js'></script>
    <script>
      // Load the Visualization API and the corechart package.
      google.charts.load('current', {'packages':['corechart']});\n"
# continue to build all the pages
page_build(pagecount)
# add all the javascript for each pie chart to each page
structure.map.with_index do |chart, ind|
  data0 = chart[0].tr('<"=: ', '')
  data1 = chart[1..-1]
  v = 'Values'
  i = ind / 50
  instance_variable_set("@page#{i > 0 ? i : ''}", instance_variable_get("@page#{i > 0 ? i : ''}") + "        google.charts.setOnLoadCallback(drawChart#{data0});\n" + draw_chart("#{data0}", data1, "#{chart[0]}", "#{v}", "#{chart_title(chart[0], ind)}", "#{data0}", width, height))
end
# restart common page region
$page = "
      $(document).ready(function () {
         'use strict';
         var last = $(location).attr('href').split('/').slice(-1)[0].split('.')[0].replace(/index/, '');
         var tab = 1;
         if (last !== '') {
           tab = parseInt(last) + 1;
         }
         $('.navbar-nav li:nth-child(' + tab + ')').addClass('selected');
         tab--;
         if (tab === 0) {
           tab = '';
         }
         $('.nuchecker a').attr('href', 'https://validator.w3.org/nu/?doc=http%3A%2F%2Fthebeast.me%2Fdashboard-2%2Findex' + tab + '.html');
      });
    </script>
  </body>
</html>"
# finish building all the pages
page_build(pagecount)
# write all the HTML pages to files
(0..pagecount).map do |i|
  file = File.open("index#{i > 0 ? i : ''}.html", 'w')
  file.write(instance_variable_get("@page#{i > 0 ? i : ''}"))
  file.close
end
