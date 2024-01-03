({
    loadDataToCalendar: function (component, data, previousView, previousMoment) {
        //Find Current date for default date
        var selected = false;
        var d = new Date();
        var month = d.getMonth() + 1;
        var day = d.getDate();
        var currentDate = d.getFullYear() + '/' +
            (month < 10 ? '0' : '') + month + '/' +
            (day < 10 ? '0' : '') + day;

        var self = this;

        let dView = 'basicDay';
        let dDate = currentDate;
        if (typeof(previousView) != 'undefined'){
            dView = previousView.name;
        }
        if (typeof(previousMoment) != 'undefined'){
            console.log(previousMoment.format());
            dDate = previousMoment.format();
        }
        $('#calendar').fullCalendar({
            header: {
                left: 'prev,next today',
                center: 'title',
                right: 'month,basicWeek,basicDay'
            },
            columnHeaderFormat: 'ddd D/M',
            selectable: true,
            defaultDate: dDate,
            editable: true,
            eventLimit: true,
            events: data,
            dragScroll: true,
            droppable: true,
            weekNumbers: true,
            weekNumberCalculation: "ISO",
            defaultView: dView,
            firstDay: '1',
            eventDrop: function (event, delta, revertFunc) {

                //alert(event.title + " was dropped on " + event.start.format());

                if (!confirm("Are you sure about this change?")) {
                    revertFunc();
                }
                else {
                    var eventid = event.id;
                    var eventdate = event.start.format();
                    self.editEvent(component, eventid, eventdate);
                }

            },
            eventClick: function (event, jsEvent, view) {

                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": event.id
                });
                editRecordEvent.fire();
            },
            dayClick: function (date, jsEvent, view) {
                /*
                var datelist = date.format().toString().split('-');

                var datetime = new Date(datelist[0], parseInt(datelist[1]) - 1, parseInt(datelist[2]) + 1, 0, 0, 0, 0);
                
                var currentuser = component.get("v.CurrentUser");

                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "Time__c",
                    "defaultFieldValues": {
                        'Date__c': datetime,
                        'Incurred_By__c': currentuser

                    }
                });
                createRecordEvent.fire();
                */
                /*
                console.log("## dayClick");
                //var evt = $A.get("e.c:registerTime");                
                var evt = component.getEvent("registerTimeFired");
                evt.setParams({"regDate": date, "currentUser" : component.get("v.CurrentUser"),
                    "startDate": null, "endDate": null, "overDay": false});
                console.dir(evt.toString());
                evt.fire();
                console.log("## Event fired");
                */
            },

            select: function(startDate, endDate) {
                  console.log("## selectClick" );
                  var overDay = false;
                  var startDateString = startDate.format();
                  var endDateString = endDate.format();;
                  var diff = endDate.diff(startDate,'days');
                  if (diff > 1){
                     overDay = true;
                     endDateString = endDate.subtract(1, 'days').format();
                  }
                  var evt = component.getEvent("registerTimeFired");
                  evt.setParams({"regDate": startDateString,
                      "currentUser" : component.get("v.CurrentUser"),
                      "startDate": startDateString, "endDate": endDate.format(), "overDay": overDay});
                  console.log(evt.getParam('overDay'));
                  evt.fire();
            },

            eventMouseover: function (event, jsEvent, view) {

            },
            viewRender: function(view, element) {                
                $.each($(".fc-day-top"), function(key, val) {
                    var dateYMD = $(this).attr("data-date");
                    $(this).append("<div><span style='color:red;' class='fc-dailytotalreg' id='dailytotalreg-"+dateYMD+"'>0</span>h|<span style='color:blue;' class='fc-dailytotalbillable' id='dailytotalbillable-"+dateYMD+"'>0</span>h</div>");
                });
                if(view.name == "basicDay" || view.name == "basicWeek") {
                    $.each($(".fc-day-header"), function(key, val) {
                        var dateYMD = $(this).attr("data-date");
                        $(this).append("<div><span style='color:red;' class='fc-dailytotalreg' id='dailytotalreg-"+dateYMD+"'>0</span>h|<span style='color:blue;' class='fc-dailytotalbillable' id='dailytotalbillable-"+dateYMD+"'>0</span>h</div>");
                    });
                }
            },
              
            eventRender: function(event, element, view) {
                $(".fc-dailytotalreg").text(0); //Clear total sum
                $(".fc-dailytotalbillable").text(0); //Clear total sum
            },
              
            eventAfterRender: function(event, element, view) {
                let currentday = moment(event.start).format("YYYY-MM-DD");
             
                //if (event.totalhrsreg > 0) {
                let prev = $("#dailytotalreg-"+currentday).text() || 0;
                $("#dailytotalreg-"+currentday).text((+prev + +event.totalhrsreg).toFixed(2));
                //  }
                //if (event.totalhrsbillable > 0) {
                prev = $("#dailytotalbillable-"+currentday).text() || 0;
                $("#dailytotalbillable-"+currentday).text((+prev + +event.totalhrsbillable).toFixed(2));
                //}
            }
        });
    },


    formatFullCalendarData: function (component, times) {
        var josnDataArray = [];
        for (var i = 0; i < times.length; i++) {            
            var startdate = $A.localizationService.formatDate(times[i].Date__c, 'yyyy-MM-dd');
            var enddate = $A.localizationService.formatDate(times[i].Date__c, 'yyyy-MM-dd');
            var createdDateTime = $A.localizationService.formatDate(times[i].CreatedDate, 'HH:mm');
            josnDataArray.push({
                'title': 'Time: ' + createdDateTime + ' Reg: ' + times[i].Registered_Hours__c + ' hrs ' + times[i].Registered_Minutes__c + ' min - Bill: ' + times[i].Billable_Hours__c + ' hrs ' + times[i].Billable_Minutes__c + ' min - ' + times[i].Time_Type__c + ' - ' + times[i].Activity__c + ' - ' + times[i].Project_Task_Name__c, 
                'start': startdate,
                'end': '', //enddate,
                'id': times[i].Id,
                'allDay' : true,
                'totalhrsbillable' : (+times[i].Billable_Hours__c + (times[i].Billable_Minutes__c / 60)).toFixed(2),
                'totalhrsreg'      : (+times[i].Registered_Hours__c + (times[i].Registered_Minutes__c / 60)).toFixed(2)
            });            
        }
        console.dir(josnDataArray);
        return josnDataArray;
        
    },

    fetchCalendarEvents: function (component, view, moment) {
        var action = component.get("c.getAllTimes");

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();

                var josnArr = this.formatFullCalendarData(component, response.getReturnValue());
                this.loadDataToCalendar(component, josnArr, view, moment);
                component.set("v.Objectlist", josnArr);

            } else if (state === "ERROR") {

            }
        });

        $A.enqueueAction(action);        

    },

    fetchCurrentUser: function (component) {
        var action = component.get("c.getCurrentUser");

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.CurrentUser", data);

            } else if (state === "ERROR") {

            }
        });

        $A.enqueueAction(action);        

    },

    editEvent: function (component, eventid, eventdate) {
        var action = component.get("c.updateTime");

        action.setParams({
            timeid: eventid,
            timedate: eventdate
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("** Successfully updated Time record.");
                this.fetchCalendarEvents(cmp);

            } else if (state === "ERROR") {

            }
        });

        $A.enqueueAction(action);

    }
})