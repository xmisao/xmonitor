class Xmonitor::Dashboard::Server < Sinatra::Application
  def self.start(context)
    @@context = context

    run!
  end

  def metric_name(metric)
    metric.join(', ')
  end

  def metric_id(metric)
    'metric-' + metric.join('-')
  end

  def output_chart_html(metric_name, datapoints)
    uuid = SecureRandom.hex(16)

    html = <<HTML
<div style="height: 200px">
<canvas id="chart-#{uuid}"></canvas>
<script>
  (function (){
    var ctx = document.getElementById("chart-#{uuid}").getContext('2d');
    ctx.canvas.height = 200;

    var myChart = new Chart(ctx, {
      type: 'line',
      data: {
        datasets: [{
          label: '#{metric_name}',
          data: #{output_data_as_json(datapoints)},
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          xAxes: [{
						type: 'time',
						distribution: 'linear',
						ticks: {
							source: 'auto'
						}
          }],
          yAxes: [{
            ticks: {
              beginAtZero: true,
            },
          }]
        },
      },
    });
  })();
</script>
</div>
HTML
  end

  def output_data_as_json(datapoints)
    datapoints.map{|dp| {'x' => dp.timestamp.iso8601, 'y' => dp.value}}.to_json
  end

  get '/' do
    @data = data

    erb :index
  end

  def data
    @@data_store ||= @@context.load_data
  end
end
