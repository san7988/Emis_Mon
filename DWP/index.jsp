<%@ page import="com.test.example"  %>
<%@ page import="com.test.HelloWorld"  %>
<!doctype html>
<html>

<head>
    <title>MY DASHBOARD</title>
 
    <style>
        canvas {
            -moz-user-select: none;
            -webkit-user-select: none;
            -ms-user-select: none;
        }
        #header {
    background-color:black;
    color:white;
    text-align:center;
    padding:5px;
}
        #average {
    background-color:black;
    color:white;
    text-align:center;
    padding:5px;
}
#average2 {
    background-color:black;
    color:white;
    text-align:center;
    padding:5px;
}
div.box {
    border: solid 1px #CCCCCC;
    background-color: #f9f9f9;
    float:left;
    padding: 4px;
    margin: 4px 4px 0px 4px;
    min-width:1000px;
}
.container {
        width:100%;
        height:200px;
}
    </style>
    <script src="Chart.bundle.js"></script>
<script src="Queue.js"></script>
<script src="http://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
    
<script>
     
        //var createMedianFilter = require('moving-median');
        var queue=new Queue();
        var output=[];
        var grand_total=0;  //maintains the total sum of all the previous data , used for calculating running average
        var grand_count=0;  //maintains the cout of all the previous data
        var sum=0; //maintains the sum of the items in the queue
        var last=0; //stores the last value read from cloud
        const threshold=15;
        var mean=0;
        //function to fetch the data to initialize the graph with
        $.ajax({
                url: "https://thingspeak.com/channels/107738/fields/1.json",
                async: false,
                dataType: 'json',
                success: function(data) {
                    //alert(data.length);
                    //alert(data.feeds[0].entry_id);
                    //alert()
                    for(var i in data.feeds){
                    output.push({value:data.feeds[i].field1, timestamp: new Date(data.feeds[i].created_at)});
                    }
                    console.log("output array length :"+output.length);
                }
            });

        for(var i=0;i<output.length;i++){
        grand_total+= + output[i].value;
        };
        grand_count=output.length;

        var MONTHS = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"];
        var randomScalingFactor = function() {
            return Math.round(Math.random() * 100 * (Math.random() > 0.5 ? -1 : 1));
        };
        var randomColorFactor = function() {
            return Math.round(Math.random() * 255);
        };
        var randomColor = function(opacity) {
            return 'rgba(' + randomColorFactor() + ',' + randomColorFactor() + ',' + randomColorFactor() + ',' + (opacity || '.3') + ')';
        };

        var config = {
            type: 'line',
            data: {
                labels: [],
                //labels: ["1", "2", "3", "4", "5", "6", "7","8"],
                datasets: [{
                    label: "My Graph",
                    data: [],
                    //data: [randomScalingFactor(), randomScalingFactor(), randomScalingFactor(), randomScalingFactor(), randomScalingFactor(), randomScalingFactor(), randomScalingFactor(),randomScalingFactor()],
                    fill: false,
                    borderDash: [5, 5],
                }]
            },
            options: {
                responsive: true,
                legend: {
                    position: 'bottom',
                },
                hover: {
                    mode: 'label'
                },
                scales: {
                    xAxes: [{
                        display: true,
                        scaleLabel: {
                            display: true,
                            labelString: 'Hour'
                        }
                    }],
                    yAxes: [{
                        display: true,
                        scaleLabel: {
                            display: true,
                            labelString: 'CO Level'
                        }
                    }]
                },
                title: {
                    display: true,
                    text: 'Real Time Emission Quality Measurement'
                }
            }
        };
        //console.log(config.data.datasets[0].data[0]);
        //populate the arrays with initial data fetched in the function above
        for(var i=0;i<output.length;i++){
        config.data.labels.push(String(output[i].timestamp.getUTCFullYear()+"-"+(output[i].timestamp.getUTCMonth()+1)+"-"+output[i].timestamp.getUTCDate()));    
        config.data.datasets[0].data.push(output[i].value);
        };
        //config.data.datasets[0].data.push(randomScalingFactor());
        //config.data.labels.push("9");
       
        $.each(config.data.datasets, function(i, dataset) {
            var background = randomColor(0.5);
            dataset.borderColor = background;
            dataset.backgroundColor = background;
            dataset.pointBorderColor = background;
            dataset.pointBackgroundColor = background;
            dataset.pointBorderWidth = 1;
        });

        window.onload = function() {
            var ctx = document.getElementById("canvas").getContext("2d");
            window.myLine = new Chart(ctx, config);
        };

        var latestUpdateTime=output[output.length-1].timestamp;
        var inter = setInterval(function () {
            updateData();
        }, 2000);

        function updateData() {
            var my_url="https://thingspeak.com/channels/107738/feeds/last.json";
            var latestOutput=[];
            //var newData = GenData(N,lastUpdateTime);
            //lastUpdateTime = newData[newData.length-1].timestamp;
            
            $.ajax({
                    url: my_url,
                    async: false,
                    dataType: 'json',
                    success: function(data) {
                        //alert(data.length);
                        //alert(data.entry_id);
                        //alert()
                        //for(var i in data){
                        latestOutput.push({value:data.field1, timestamp: new Date(data.created_at)});
                        //console.log("latest va 1 : "+data.field1);
                        //}
                    }
                });
            if(+latestUpdateTime == +latestOutput[0].timestamp){
                console.log("equal timestamp so didnt update");
            }
            else{
                //output.push({value:latestOutput[0].value, timestamp: latestOutput[0].timestamp});
                latestUpdateTime=latestOutput[0].timestamp;
                config.data.labels.push(String(latestOutput[0].timestamp.getUTCFullYear()+"-"+(latestOutput[0].timestamp.getUTCMonth()+1)+"-"+latestOutput[0].timestamp.getUTCDate()));
                config.data.datasets[0].data.push(latestOutput[0].value);
                window.myLine.update();
                var temp= +latestOutput[0].value;
                //console.log("value1 :"+value);
                runningAvg(temp);
                updateQueue(+latestOutput[0].value);
                }
            
            
        };
  
        //function calcRunningAverage(value){
          //  console.log("value2 :"+value);
            //document.getElementById('average').innerHTML = "Running Average :"+Math.round((runningAvg(value)+ 0.00001) * 100) / 100;
            //console.log("dingu");
        //};
    
        function runningAvg(value){   
        
            //count=output.length;
            console.log("total :"+grand_total);
            console.log("value3 :"+value);
            if (typeof value !== 'undefined') {
            grand_total=grand_total + value;
            grand_count+=1;
            }
            console.log("total :"+grand_total);
        console.log("total :"+grand_count);
        var output1 = grand_total/grand_count;
        return output1;
        };

        function testfunc(){
            
            document.getElementById('average').innerHTML = "Running Average :"+Math.round( (grand_total/grand_count + 0.00001) * 100) / 100;
        };
        function testfunc2(){
            
            document.getElementById('average2').innerHTML = "Average (last 5 values):"+Math.round( (mean + 0.00001) * 100) / 100;
            var temp=document.getElementById("average2");
            if(mean > threshold && queue.getLength() >=  5){
            	temp.style.backgroundColor = 'red';
            	var refreshId = setInterval(function()
            			{
            			     $('#average2').fadeOut("slow").load().fadeIn("slow");
            			     //console.log($('#responsecontainer').html());
            			}, 1000);
            }
            else {
            	temp.style.backgroundColor = 'green';
            		
            }
        };
        //function updateQueue2(value){
          //  document.getElementById('average2').innerHTML = "Average (last 5 values): "+Math.round((updateQueue(value) + 0.00001) * 100) / 100;
        //};
        function updateQueue(value){
            if(typeof value != 'undefined'){
            sum= sum + value;
            
            if (queue.getLength() < 5) {
                console.log("value in update method :"+value);
                queue.enqueue(value);
                mean=sum/queue.getLength();
            }
            else if (queue.getLength() == 5) {
                var temp= +queue.dequeue();
                sum=sum - temp;
                queue.enqueue(value);
                mean=sum/queue.getLength();
                if (queue.peek() > threshold && mean > threshold) {
                    console.log("mean is : "+mean + " sum is :" + sum + " ...now it's time to send msg");
                    get();
                }
                else console.log("situation under control");
            }
            }
            console.log("In update queue, sum is :" + sum+" mean is : "+mean);
            return mean;
        };
    
        function get(){ 
        	console.log("reached here");
        	var m=mean; 
        	window.location.replace("index.jsp?mess="+m);
        }; 
    </script>

</head>

<body>

    <div id="header">
    <h1>Vehicle Id : ABC456X</h1>
    </div>
 
    <div style="public class HelloWorld {

}
    width:75%;">
        <canvas id="canvas"></canvas>
    </div>
    <br>
    <br>
    <div id="average">Running Average : <script type="text/javascript">var inter = setInterval(function () {
            testfunc();
        }, 2000);</script> </div>
    <div id="average2">Average (last 5 values): <script type="text/javascript">
    var inter = setInterval(function () {
            testfunc2();
        }, 2000);
    </script> 
    
    
    </div>
  <input type="button" onclick=get() value=click>   
<%String message=request.getParameter("mess");
	//float f =Float.parseFloat(message);
	//example ex=new example();
	//ex.sendSMS();
	System.out.println("here also");
	if(message!=null){
		example ex=new example();
		ex.sendSMS(message);
	HelloWorld hw=new HelloWorld();
	hw.printSample();
	}
System.out.println(message);
%> 
    
</body>

</html>
