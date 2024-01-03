({

	afterScriptsLoaded: function(cmp,evt,helper){		
		helper.fetchCalendarEvents(cmp);
		helper.fetchCurrentUser(cmp);
	},
	
	handleEventSave: function(component, event, helper) {
	    console.log('handleEventSave');
        let view = $('#calendar').fullCalendar('getView');
        let moment = $('#calendar').fullCalendar('getDate');
        $('#calendar').fullCalendar('destroy');
        helper.fetchCalendarEvents(component, view, moment);
	},

	handleClick : function(component, event, helper){
		var buttonstate = component.get("v.buttonstate");
		component.set("v.buttonstate",!buttonstate);
		if(!buttonstate){
		 $("#listcalendar").show();
		$("#calendar").hide();
		$('#listcalendar').fullCalendar({
		   defaultView: 'Day',
			listDayFormat : true,
			displayEventTime: false,
			events : component.get("v.Objectlist")
	   });
	   
		}
		else{
			 $("#calendar").show();
		  $("#listcalendar").hide();   
			helper.fetchCalendarEvents(component);
		}
	   
   },

   handleLoadModal: function(component, event, helper) {
	console.log("## Handling event registerTime ");
	console.log(event.getParams().overDay);
	var modalBody;
	$A.createComponent("c:TimeRegistration", {"regDate": event.getParams().regDate,
	   "CurrentUser": event.getParams().currentUser, "overDay": event.getParams().overDay, "startDate":
	    event.getParams().startDate, "endDate": event.getParams().endDate},
	   function(content, status) {
		   if (status === "SUCCESS") {
			   modalBody = content;
			   component.find('overlayLib').showCustomModal({
				   header: "Register Time",
				   body: modalBody,
				   showCloseButton: true,				   
				   closeCallback: function() {	
					   			   			   
					   //$A.get('e.force:refreshView').fire()					   
					   console.log("## View refreshed")
					   component.set("v.modalPromise", undefined);
					   let view = $('#calendar').fullCalendar('getView');
                       let moment = $('#calendar').fullCalendar('getDate');
					   $('#calendar').fullCalendar('destroy');
					   helper.fetchCalendarEvents(component, view, moment);
				   
				   }
			   }).then(function (overlay) {
				component.set("v.modalPromise", overlay);				
			});
		   } 
	   });
	},
	handleCloseModal: function(component, event) {
		console.log("## Handling event closeTimeRegistrationModal");
		let overlay = component.get("v.modalPromise")
		console.dir(overlay);
		if (overlay) { overlay.close(); }
	}
})