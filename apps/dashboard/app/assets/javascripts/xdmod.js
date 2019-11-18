function initXdmodDashboard(){


Ext.BLANK_IMAGE_URL = 'https://xdmod-test.hpc.osc.edu/gui/lib/extjs/resources/images/default/s.gif';
function getDateRanges() {
  var today = new Date();
  var yesterday = today.add(Date.DAY, -1);
  var lastWeek = today.add(Date.DAY, -7);
  var lastMonth = today.add(Date.DAY, -30);
  var lastQuarter = today.add(Date.DAY, -90);
  var lastYear = today.add(Date.YEAR, -1);
  var yearToDate = today.add(Date.DAY, -1 * today.getDayOfYear());
  var thisYearStart = today.add(Date.DAY, -1 * today.getDayOfYear());
  var thisYearEnd = new Date(thisYearStart.getFullYear(), 11, 31, 23, 59, 59, 999);
  var last2Year = today.add(Date.YEAR, -2);
  var last3Year = today.add(Date.YEAR, -3);
  var last5Year = today.add(Date.YEAR, -5);
  var last10Year = today.add(Date.YEAR, -10);

  var thisMonthStart = new Date(today.getFullYear(), today.getMonth(), 1);

  var thisQuarterStart = new Date(today.getFullYear(), today.getMonth() - (today.getMonth() % 3), 1);
  var thisQuarterEnd = new Date(today.getMonth() < 9 ? today.getFullYear() : today.getFullYear() + 1, (today.getMonth() - (today.getMonth() % 3) + 3) % 12, 1).add(Date.DAY, -1);
  var lastQuarterStart = new Date(today.getMonth() < 3 ? today.getFullYear() - 1 : today.getFullYear(), (today.getMonth() - (today.getMonth() % 3) + 9) % 12, 1);
  var lastQuarterEnd = new Date(thisQuarterStart).add(Date.DAY, -1);

  var lastFullMonthStart = new Date(today.getMonth() < 1 ? today.getFullYear() - 1 : today.getFullYear(), today.getMonth() < 1 ? 11 : (today.getMonth() - 1), 1);
  var lastFullMonthEnd = thisMonthStart.add(Date.DAY, -1);

  var oneYearAgoStart = new Date(today.getFullYear() - 1, 0, 1);
  var oneYearAgoEnd = new Date(today.getFullYear() - 1, 11, 31);

  var twoYearAgoStart = new Date(today.getFullYear() - 2, 0, 1);
  var twoYearAgoEnd = new Date(today.getFullYear() - 2, 11, 31);

  var threeYearAgoStart = new Date(today.getFullYear() - 3, 0, 1);
  var threeYearAgoEnd = new Date(today.getFullYear() - 3, 11, 31);

  var fourYearAgoStart = new Date(today.getFullYear() - 4, 0, 1);
  var fourYearAgoEnd = new Date(today.getFullYear() - 4, 11, 31);

  var fiveYearAgoStart = new Date(today.getFullYear() - 5, 0, 1);
  var fiveYearAgoEnd = new Date(today.getFullYear() - 5, 11, 31);

  var sixYearAgoStart = new Date(today.getFullYear() - 6, 0, 1);
  var sixYearAgoEnd = new Date(today.getFullYear() - 6, 11, 31);

  // NOTE: Changes to this array may affect the default duration.
  // Please ensure defaultCannedDateIndex points to the correct entry.
  return [{
    text: 'Yesterday',
    start: yesterday,
    end: yesterday
  }, {
    text: '7 day',
    start: lastWeek,
    end: today
  }, {
    text: '30 day',
    start: lastMonth,
    end: today
  }, {
    text: '90 day',
    start: lastQuarter,
    end: today
  }, {
    text: 'Month to date',
    start: thisMonthStart,
    end: today
  }, {
    text: 'Previous month',
    start: lastFullMonthStart,
    end: lastFullMonthEnd
  }, {
    text: 'Quarter to date',
    start: thisQuarterStart,
    end: today
  }, {
    text: 'Previous quarter',
    start: lastQuarterStart,
    end: lastQuarterEnd
  }, {
    text: 'Year to date',
    start: thisYearStart,
    end: today
  }, {
    text: 'Previous year',
    start: oneYearAgoStart,
    end: oneYearAgoEnd
  }, {
    text: '1 year',
    start: lastYear,
    end: today
  }, {
    text: '2 year',
    start: last2Year,
    end: today
  }, {
    text: '3 year',
    start: last3Year,
    end: today
  }, {
    text: '5 year',
    start: last5Year,
    end: today
  }, {
    text: '10 year',
    start: last10Year,
    end: today
  }, {
    text: thisYearStart.getFullYear(),
    start: thisYearStart,
    end: thisYearEnd
  }, {
    text: '' + oneYearAgoStart.getFullYear(),
    start: oneYearAgoStart,
    end: oneYearAgoEnd
  }, {
    text: '' + twoYearAgoStart.getFullYear(),
    start: twoYearAgoStart,
    end: twoYearAgoEnd
  }, {
    text: '' + threeYearAgoStart.getFullYear(),
    start: threeYearAgoStart,
    end: threeYearAgoEnd
  }, {
    text: '' + fourYearAgoStart.getFullYear(),
    start: fourYearAgoStart,
    end: fourYearAgoEnd
  }, {
    text: '' + fiveYearAgoStart.getFullYear(),
    start: fiveYearAgoStart,
    end: fiveYearAgoEnd
  }, {
    text: '' + sixYearAgoStart.getFullYear(),
    start: sixYearAgoStart,
    end: sixYearAgoEnd
  }];
}

function filterRange(arr, label) {
  var dateRange = {};
  for (var i = 0; i < arr.length; i++) {
    if (arr[i].text === label) {
      dateRange = {
        start_date: arr[i].start.format('Y-m-d'),
        end_date: arr[i].end.format('Y-m-d')
      };
    }
  }
  return dateRange;
}

Ext.onReady(function () {

  /*
   * ------------------------------------------------------------
   * Start Job Efficiency
   * ------------------------------------------------------------
   */

    var formatDateWithTimezone = function (value) {
    return moment(value * 1000).format('Y-MM-DD HH:mm:ss z');
    };

    var jobEfficiency = function (value, metadata, record) {
    var getDataColor = function (data) {
    var color = 'gray';
    var steps = [{
value: 0.25,
color: '#FF0000'
}, {
value: 0.50,
color: '#FFB336'
}, {
value: 0.75,
         color: '#DDDF00'
}, {
value: 1,
         color: '#50B432'
}];

var i;
var step;
for (i = 0; i < steps.length; i++) {
  step = steps[i];
  if (data <= step.value) {
    color = step.color;
    break;
  }
}
return color;
};

if (record.data.cpu_user === null || record.data.cpu_user < 0) {
  return '<div class="job-metric-na">N/A</div>';
}

metadata.attr = 'ext:qtip="CPU Usage ' + (record.data.cpu_user * 100.0).toFixed(1) + '%"';

return String.format('<div class="circle" style="background-color: {0}"></div>', getDataColor(record.data.cpu_user));
};

var columns = [{
header: 'Job Identifier',
          width: 140,
          tooltip: 'The job identifier includes the resource that ran the job and the id provided by the resource manager.',
          dataIndex: 'text'
}, {
header: 'Start',
          renderer: formatDateWithTimezone,
          tooltip: 'The start time of the job',
          width: 115,
          fixed: true,
          dataIndex: 'start_time_ts'
}, {
header: 'End',
          renderer: formatDateWithTimezone,
          tooltip: 'The end time of the job',
          width: 115,
          fixed: true,
          dataIndex: 'end_time_ts'
}, {
header: 'CPU',
          renderer: jobEfficiency,
          tooltip: 'The average CPU usage for the job. The text NA indicates that the metric is unavailable.',
          width: 40,
          fixed: true,
          dataIndex: 'cpu_user'
}];

if (true) { // fix this
  columns.splice(0, 0, {
header: 'Person',
width: 90,
sortable: true,
dataIndex: 'name'
});
}

var jobStore = new Ext.data.JsonStore({
restful: true,
url: "https://xdmod-test.hpc.osc.edu/rest/v1/warehouse/search/jobs",
root: 'results',
cors: true,
withCredentials: true,
useDefaultXhrHeader: false,
autoLoad: true,
totalProperty: 'totalCount',
baseParams: {
start_date: moment().subtract(30, 'days').format("YYYY-MM-DD"),
end_date: moment().format("YYYY-MM-DD"),
realm: 'Jobs',
limit: 10,
start: 0,
verbose: true,
params: JSON.stringify({})
},
fields: [{
name: 'dtype',
mapping: 'dtype',
type: 'string'
        }, {
name: 'resource',
      mapping: 'resource',
      type: 'string'
        }, {
name: 'name',
      mapping: 'name',
      type: 'string'
        }, {
name: 'jobid',
      mapping: 'jobid',
      type: 'int'
        }, {
name: 'local_job_id',
      mapping: 'local_job_id',
      type: 'int'
        }, {
name: 'text',
        mapping: 'text',
        type: 'string'
        },
        'cpu_user',
        'start_time_ts',
        'end_time_ts'
        ]
        });

var jobsGridPanel = {
xtype: 'grid',
       store: jobStore,
       enableHdMenu: false,
       loadMask: true,
       stripeRows: true,
       height: 300,
       frame: true,
       cls: 'job-component-grid',
       colModel: new Ext.grid.ColumnModel({
defaults: {
sortable: true
},
columns: columns
}),
viewConfig: {
emptyText: '<div class="no-data-alert">No Job Records Found</div><div class="no-data-info">Job information only shows in XDMoD once the job has finished and there is a short delay between a job finishing and the job&apos;s data being available in XDMoD.</div>',
           forceFit: true
            },
bbar: new Ext.PagingToolbar({
store: jobStore,
displayInfo: true,
pageSize: 10,
prependButtons: true
}),
sm: new Ext.grid.RowSelectionModel({
singleSelect: true
}),
listeners: {
rowclick: function (panel, rowIndex) {
            var store = panel.getStore();
            var info = store.getAt(rowIndex);
            var params = {
action: 'show',
        realm: store.baseParams.realm,
        jobref: info.data[info.data.dtype]
            };
            window.open('https://xdmod-test.hpc.osc.edu/#job_viewer?' + Ext.urlEncode(params));
          }
           }
};

var jobsPanel = new Ext.Panel({
renderTo: 'jobsPanelDiv',
items: [jobsGridPanel],
height: 325,
width: 1200,
title: 'Jobs - ' + moment().subtract(30, 'days').format("YYYY-MM-DD") + ' to ' + moment().format("YYYY-MM-DD")
})


/*
 * ------------------------------------------------------------
 * End Job Efficiency
 * ------------------------------------------------------------
 */

/*
 * ------------------------------------------------------------
 * Start Center Report Card
 * ------------------------------------------------------------
 */

var centerReportCardGridStore = new Ext.data.JsonStore({
storeId: 'center-report-card-store',
root: 'results',
autoLoad: true,
fields: [
'resource',
'app_kernel',
'failedRuns',
'inControlRuns',
'overPerformingRuns',
'underPerformingRuns'
],
proxy: new Ext.data.HttpProxy({
method: 'GET',
url: 'https://xdmod-test.hpc.osc.edu/rest/v1/app_kernels/performance_map/raw'
}),
baseParams: {
start_date: moment().startOf('year').format("YYYY-MM-DD"),
end_date: moment().format("YYYY-MM-DD")
}
});

var valueRenderer = function (value, metaData, record) {
  var failed = record.get('failedRuns');
  var inControl = record.get('inControlRuns');
  var overPerforming = record.get('overPerformingRuns');
  var underPerforming = record.get('underPerformingRuns');

  var total = failed + inControl + overPerforming + underPerforming;

  /**
   * Constructs an svg `rect` element based on the provided attributes.
   * This will be used in a stacked horizontal bar chart.
   *
   * @param id     {String} The id to use for the rect element.
   * @param title  {String} The title to display for this elements tooltip
   * @param msg    {String} The msg to display w/ this elements tooltip
   * @param width  {Number} The width of this element ( will be interpreted as a percentage ).
   * @param x      {Number} The distance from the left that this element should reside ( will be interpreted as a percentage ).
   * @param height {Number} The height of this rect element.
   * @param red    {Number} The r of this elements rgb.
   * @param green  {Number} The g of this elements rgb.
   * @param blue   {Number} The b of this elements rgb.
   *
   * @returns {string} for an svg rect element
   */
  var rect = function (id, title, msg, width, x, height, red, green, blue) {
    var xValue = x + '%';
    if (Ext.isChrome) {
      xValue = 'calc(' + x + '% + 1px)';
    }
    return [
      '<rect id="' + id + '"',
      'width="' + width + '%"',
      'height="' + height + '"',
      'x="' + xValue + '"',
      'style="fill:rgb(' + red + ',' + green + ',' + blue + ');',
      'stroke-width:1; stroke:rgb(0,0,0)" ',
      'ext:qtitle="' + title + '"',
      'ext:qtip="' + msg + '"',
      'ext:qwidth="120" />'
    ].join(' ');
  };

  var height = 17;

  // Make sure that we have at least some runs
  if (total > 0) {
    var contents = [
      '<div style="width: 100%;">',
      '<svg width="100%" height="' + height + '">'
    ];

    var input = {
      'ak-failed': {
title: 'Failed Runs',
       red: 255,
       green: 0,
       blue: 0,
       runs: failed
      },
      'ak-underperforming': {
title: 'Under Performing Runs',
       red: 255,
       green: 179,
       blue: 54,
       runs: underPerforming
      },
      'ak-incontrol': {
title: 'In Control Runs',
       red: 80,
       green: 180,
       blue: 50,
       runs: inControl
      },
      'ak-overperforming': {
title: 'Over Performing Runs',
       red: 66,
       green: 134,
       blue: 255,
       runs: overPerforming
      }
    };

    var sum = 0;
    for (var id in input) {
      if (input.hasOwnProperty(id)) {
        var runs = input[id].runs;
        var percentage = total > 0 ? Math.round(((runs / total) * 100)) : 0;
        var msg = percentage + '% - (' + runs + ' out of ' + total + ')';

            contents.push(
              rect(id, input[id].title, msg, percentage, sum, height, input[id].red, input[id].green, input[id].blue)
              );

    sum += percentage;
    }
    }

    contents.push('</svg>');
    contents.push('</div>');
    } else {
    // If we don't have any runs then just output a simple message
    // to let the user know what's up.
    // eslint-disable-next-line block-scoped-var
    contents = [
    '<div style="width:100%; height: ' + height + ';">',
    '<span style="font-weight: bold">No Data Found!</span>',
    '</div>'
    ];
    }

  // eslint-disable-next-line block-scoped-var
  return contents.join(' ');
}; // var valueRenderer = function (value, metaData, record) {

var centerReportCardGrid = new Ext.grid.GridPanel({
enableHdMenu: false,
loadMask: true,
stripeRows: true,
height: 300,
frame: true,
store: centerReportCardGridStore,
autoExpandColumn: 'ak-status',
colModel: new Ext.grid.ColumnModel({
columns: [{
id: 'ak-resource',
header: 'Resource',
dataIndex: 'resource',
width: 90
}, {
id: 'ak-name',
header: 'App Kernel',
dataIndex: 'app_kernel',
width: 190
}, {
id: 'ak-status',
header: 'Status',
dataIndex: 'inControlRuns',
renderer: valueRenderer
}]
}),
viewConfig: new Ext.grid.GridView({
emptyText: 'No App Kernel information available.'
}),
listeners: {

             /**
              * Fires when the user clicks on a row. In this case we construct
              * a new History token that will direct the UI to the App Kernel
              * Performance Map tab w/ the currently selected start date and
              * end date so that the tabs duration toolbar can be set correctly.
              * The resource / app kernel is also included so that the correct
              * first row can be selected.
              *
              * @param {Ext.grid.GridPanel} grid
              * @param {number}             rowIndex
              */
rowclick: function (grid, rowIndex) {
            var record = grid.getStore().getAt(rowIndex);

            var info = {
start_date: moment().startOf('year').format("YYYY-MM-DD"),
            end_date: moment().format("YYYY-MM-DD"),
            resource: record.get('resource'),
            app_kernel: record.get('app_kernel')
            };

            var token = 'https://xdmod-test.hpc.osc.edu/#main_tab_panel:app_kernels:app_kernel_performance_map?ak=' + window.btoa(JSON.stringify(info));

            window.open(token);
          }
           }
}); // this.grid

var centerReportCardPanel = new Ext.Panel({
renderTo: 'centerReportCardPanelDiv',
items: [centerReportCardGrid],
width: 1200,
height: 325,
title: 'Center Report Card - ' + moment().subtract(30, 'days').format("YYYY-MM-DD") + ' to ' + moment().format("YYYY-MM-DD")
})

    /*
     * ------------------------------------------------------------
     * End Center Report Card
     * ------------------------------------------------------------
     */

/*
 * ------------------------------------------------------------
 * Start Summary Charts
 * ------------------------------------------------------------
 */


var xd = Ext.data;

// default timeframe is the past 30 days
var today = new Date();
var lastMonth = today.add(Date.DAY, -30);
var start = lastMonth.format('Y-m-d');
var end = today.format('Y-m-d');

var timeframe = {
start_date: start,
            end_date: end
};

var timeframe_label = '30 day'

var reportThumbnailsStore = new Ext.data.JsonStore({
  url: 'https://xdmod-test.hpc.osc.edu/rest/v1/dashboard/rolereport',
  cors: true,
  withCredentials: true,
  useDefaultXhrHeader: false,
  root: 'data.queue',
  fields: [
    'chart_title', {
      name: 'thumbnail_link',
      convert: function (v, rec) {
        var params = {};
        var v_split = v.split('/report_image_renderer.php?')[1].split('&');
        for (var index = 0; index < v_split.length; index++) {
          var tmpk = v_split[index].split('=')[0];
          var tmpv = v_split[index].split('=')[1];
          params[tmpk] = tmpv;
        }
        var value;
        if (!(timeframe.start_date === null && timeframe.end_date === null)) {
          value = '/report_image_renderer.php?type=cached&ref=' + params.ref;
          value = value + '&start=' + timeframe.start_date + '&end=' + timeframe.end_date;
        } else {
          value = '/report_image_renderer.php?type=report&ref=' + params.ref;
        }
        return value;


      }
    }
  ]
  });
  reportThumbnailsStore.load();

  var tpl = new Ext.XTemplate(
    '<tpl for=".">',
    '<div class="thumb-wrap" id="{chart_title}">',
    '<span class="x-editable">{shortName}</span>',
    '<div class="thumb"><img src="https://xdmod-test.hpc.osc.edu/{thumbnail_link}"></div>',
    '</div>',
    '</tpl>',
    '<div class="x-clear"></div>'
  );

  var reportThumbnailsPanel = new Ext.Panel({
    id: 'images-view',
    frame: true,
    width: 1200,
    //autoHeight:true, collapsible:true,
    renderTo: 'reportThumbnailsPanelDiv',
    layout: 'fit',
    title: 'Summary Charts',
    tbar: {
      items: [{
        xtype: 'tbtext',
        text: 'Time Range'
      }, {
        xtype: 'button',
        text: timeframe_label,
        menu: [{
          text: '30 day',
          checked: timeframe_label === '30 day',
          group: 'timeframe',
          listeners: {
            click: function (comp) {
              timeframe_label = '30 day';
              var today = new Date();
              var lastMonth = today.add(Date.DAY, -30);
              var start = lastMonth;
              var end = today;

              this.ownerCt.ownerCt.ownerCt.ownerCt.fireEvent('timeframe_change', start, end);
              this.ownerCt.ownerCt.ownerCt.items.items[1].setText('30 day');
              this.ownerCt.ownerCt.ownerCt.items.items[2].setText('<b>' + timeframe.start_date + ' to ' + timeframe.end_date + '</b>');
            }
          }
        }, {
          text: '1 year',
          checked: timeframe_label === '1 year',
          group: 'timeframe',
          listeners: {
            click: function () {
              timeframe_label = '1 year';
              var today = new Date();
              var lastYear = today.add(Date.YEAR, -1);
              var start = lastYear;
              var end = today;
              this.ownerCt.ownerCt.ownerCt.ownerCt.fireEvent('timeframe_change', start, end);
              this.ownerCt.ownerCt.ownerCt.items.items[1].setText('1 year');
              this.ownerCt.ownerCt.ownerCt.items.items[2].setText('<b>' + timeframe.start_date + ' to ' + timeframe.end_date + '</b>');
            }
          }
        }, {
          text: '5 year',
          checked: timeframe_label === '5 year',
          group: 'timeframe',
          listeners: {
            click: function () {
              timeframe_label = '5 year';
              var today = new Date();
              var last5Year = today.add(Date.YEAR, -5);
              var start = last5Year;
              var end = today;
              this.ownerCt.ownerCt.ownerCt.ownerCt.fireEvent('timeframe_change', start, end);
              this.ownerCt.ownerCt.ownerCt.items.items[1].setText('5 year');
              this.ownerCt.ownerCt.ownerCt.items.items[2].setText('<b>' + timeframe.start_date + ' to ' + timeframe.end_date + '</b>');
            }
          }
        }, {
          text: 'Report default',
          checked: timeframe_label === 'Report default',
          group: 'timeframe',
          listeners: {
            click: function (comp) {
              timeframe_label = 'Report default';
              this.ownerCt.ownerCt.ownerCt.ownerCt.fireEvent('timeframe_change');
              this.ownerCt.ownerCt.ownerCt.items.items[1].setText('Report default');
              this.ownerCt.ownerCt.ownerCt.items.items[2].setText('');
            }
          }
        }]
      }, {
        xtype: 'tbtext',
        text: (timeframe.start_date !== null && timeframe.end_date !== null ? '<b>' + timeframe.start_date + ' to ' + timeframe.end_date + '</b>' : '')
      }]
    },
    listeners: {
      timeframe_change: function (start_date, end_date) {
        if (start_date !== undefined && end_date !== undefined) {
          timeframe.start_date = start_date.format('Y-m-d');
          timeframe.end_date = end_date.format('Y-m-d');
        } else {
          timeframe.start_date = null;
          timeframe.end_date = null;
        }
        reportThumbnailsStore.load();
      }
    },
    items: new Ext.DataView({
      store: reportThumbnailsStore,
      tpl: tpl,
      autoHeight: true,
      multiSelect: true,
      overClass: 'x-view-over',
      itemSelector: 'div.thumb-wrap',
      emptyText: 'No images to display',

      prepareData: function (data) {
        data.shortName = Ext.util.Format.ellipsis(data.chart_title, 50);
        var params = {};
        var v_split = data.thumbnail_link.split('/report_image_renderer.php?')[1].split('&');
        for (var index = 0; index < v_split.length; index++) {
          var tmpk = v_split[index].split('=')[0];
          var tmpv = v_split[index].split('=')[1];
          params[tmpk] = tmpv;
        }
        data.report_id = params.ref.split(';')[0];
        return data;
      },
      listeners: {
        click: {
          fn: function (dataView, index, node, e) {
            var config = JSON.parse(JSON.stringify(dataView.store.data.items[index].json.chart_id));
            var config_link = {};
            var config_data = {};
            config_data.operation = 'get_data';
            for (var key in config) {
              if (key === 'data_series') {
                var data_series = {};
                data_series.data = config[key];
                data_series.total = config[key].length;
                config_link.data_series = data_series;
                config_data[key] = Ext.util.JSON.encode(config[key]);
              } else if (key === 'global_filters') {
                config_link[key] = config[key];
                config_data[key] = Ext.util.JSON.encode(config[key]);
              } else {
                config_data[key] = config[key];
                config_link[key] = config[key];
              }
            }

            if (!(timeframe.start_date === null && timeframe.end_date === null)) {
              config_link.start_date = timeframe.start_date;
              config_link.end_date = timeframe.end_date;
              config_link.timeframe_label = 'User Defined';
              config_data.start_date = timeframe.start_date;
              config_data.end_date = timeframe.end_date;
              config_data.timeframe_label = 'User Defined';

            } else {
              var ranges = getDateRanges();
              var timeframeRange = filterRange(ranges, config.timeframe_label);
              config_link.start_date = timeframeRange.start_date;
              config_link.end_date = timeframeRange.end_date;
              config_data.start_date = timeframeRange.start_date;
              config_data.end_date = timeframeRange.end_date;
            }
            var win = new Ext.Window({
              layout: 'fit',
              width: 1000,
              height: 600,
              closeAction: 'destroy',
              plain: true,
              title: dataView.store.data.items[index].json.chart_title,
              items: [{ // Let's put an empty grid in just to illustrate fit layout

                html: '<div id="container"></div>'
              }],
              buttons: [{
                text: 'Open in Metric Explorer',
                handler: function () {
                  win.destroy();
                  var url = "https://xdmod-test.hpc.osc.edu/#main_tab_panel:metric_explorer?config=" + window.btoa(JSON.stringify(config_link));

                  window.open(url, '_blank');
                }
              }, {
                text: 'Close',
                handler: function () {
                  win.destroy();
                }
              }]
            });

            win.show();

            $.ajax({
              url: "https://xdmod-test.hpc.osc.edu/controllers/metric_explorer.php",
              data: config_data,
              method: "POST",
              xhrFields: {
                withCredentials: true
              },
              crossDomain: true,
              success: function (data) {
                data = JSON.parse(data)
                data = data.data[0];
                data.chart.renderTo = 'container';
                data.chart.height = 520
                if (data.series.length == 0) {
                  data.title.text = 'No data available for the critera specified';
                  data.title.verticalAlign = 'middle';
                  data.title.floating = true;
                  data.title.style = { "color": "#333333", "fontSize": "40px" }
                }
                var chart = new Highcharts.Chart(data);
              }
            });

          }
        }
      }

    })
  });

  /*
   * ------------------------------------------------------------
   * End Summary Charts
   * ------------------------------------------------------------
   */

});

}
