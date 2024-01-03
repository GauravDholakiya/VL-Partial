({
	doInit : function(component, event, helper) {
		var action = component.get("c.getDependentPicklist");
		
		action.setParams({
			ObjectName : component.get("v.objectName"),
			parentField : component.get("v.parentFieldAPI"),
			childField : component.get("v.childFieldAPI")
		});
		
		action.setCallback(this, function(response){
		 	var status = response.getState();
			if(status === "SUCCESS"){
				var pickListResponse = response.getReturnValue();
				console.log("## Child Picklist Map");
				console.dir(pickListResponse.pickListMap);

				//save response 
				component.set("v.childPickListMap",pickListResponse.pickListMap);
				component.set("v.parentFieldLabel",pickListResponse.parentFieldLabel);
				component.set("v.childFieldLabel",pickListResponse.childFieldLabel);
				
				// create a empty array for store parent picklist values 
				var parentkeys = []; // for store all map keys 
				var parentField = []; // for store parent picklist value to set on lightning:select. 
				
				// Iterate over map and store the key
				for (var pickKey in pickListResponse.pickListMap) {
					parentkeys.push(pickKey);
				}
				
				//set the parent field value for lightning:select
				if (parentkeys != undefined && parentkeys.length > 0) {
					parentField.push('--- None ---');
				}
				
				for (var i = 0; i < parentkeys.length; i++) {
					parentField.push(parentkeys[i]);
				}  
			   console.log("## Parent Picklist constructed:");
			   console.dir(parentField);
			   
				// set the parent picklist
				component.set("v.parentList", parentField);
				
			}
		});
		
		$A.enqueueAction(action);

		var action2 = component.get("c.getDependentPicklist");

		action2.setParams({
			ObjectName : component.get("v.objectName"),
			parentField : component.get("v.firstParentFieldAPI"),
			childField : component.get("v.parentFieldAPI")
		});

		action2.setCallback(this, function(response){
			var status = response.getState();
		   if(status === "SUCCESS"){
			   var pickListResponse = response.getReturnValue();
			   console.log("## Parent Picklist Map");
			   console.dir(pickListResponse.pickListMap);

			   //save response 
			   component.set("v.parentPickListMap",pickListResponse.pickListMap);
			   component.set("v.firstParentFieldLabel",pickListResponse.parentFieldLabel);
			   component.set("v.parentFieldLabel",pickListResponse.childFieldLabel);
			   
			   // create a empty array for store parent picklist values 
			   var parentkeys = []; // for store all map keys 
			   var parentField = []; // for store parent picklist value to set on lightning:select. 
			   
			   // Iterate over map and store the key
			   for (var pickKey in pickListResponse.pickListMap) {
				   parentkeys.push(pickKey);
			   }
			   
			   //set the parent field value for lightning:select
			   if (parentkeys != undefined && parentkeys.length > 0) {
				   parentField.push('--- None ---');
			   }
			   
			   for (var i = 0; i < parentkeys.length; i++) {
				   parentField.push(parentkeys[i]);
			   }  
			   console.log("## First Parent Picklist constructed:");
			   console.dir(parentField);

			   // set the parent picklist
			   component.set("v.firstParentList", parentField);
			   
		   }
	   });
	   
	   $A.enqueueAction(action2);

	},

    firstParentFieldChange : function(component, event, helper) {
        console.log("## BEGIN firstParentFieldChange");
        var controllerValue = component.get("v.firstParentValue"); // We can also use event.getSource().get("v.value")
        console.log("## controllerValue: "+ controllerValue);
        var pickListMap = component.get("v.parentPickListMap");
        console.log("## pickListMap: ");
        console.dir(pickListMap);
         
        if (controllerValue != '--- None ---') {
			 //get child picklist value
			var isParentValueInList = false;
			var parentValue = component.get("v.parentValue");
            var childValues = pickListMap[controllerValue];
            var childValueList = [];
			childValueList.push('--- None ---');
            for (var i = 0; i < childValues.length; i++) {
				if (parentValue == childValues[i]) {
					isParentValueInList = true;
				}
                childValueList.push(childValues[i]);
			}
			if (!isParentValueInList) {
				component.set("v.parentValue","--- None ---");
			}
            console.log("## Child value list:")
            console.dir(childValueList);
            // set the child list
            component.set("v.parentList", childValueList);
            
            if(childValues.length > 0){
                component.set("v.disabledParentField" , false);  
                component.set("v.childList", ['--- None ---']);
                component.set("v.disabledChildField" , true);
            }else{
                component.set("v.disabledParentField" , true); 
                component.set("v.childList", ['--- None ---']);
                component.set("v.disabledChildField" , true);
            }
            
        } else {
            component.set("v.parentList", ['--- None ---']);
            component.set("v.disabledParentField" , true);
            component.set("v.childList", ['--- None ---']);
            component.set("v.disabledChildField" , true);
		}
		
		var isSelectedProjectInternal = helper.isSelectedProjectInternal(component);
		if (isSelectedProjectInternal) {
			var parentList = component.get("v.parentList");
			for (var i = 0; i < parentList.length; i++) {
				if (parentList[i] == "Internal") {
					component.set("v.parentValue", "Internal");
                    component.set("v.childValue","9000 Internal work");
					$A.enqueueAction(component.get('c.parentFieldChange'));
					break;
				} else if (parentList[i] == "Interntid") {
					component.set("v.parentValue", "Interntid");
					$A.enqueueAction(component.get('c.parentFieldChange'));
					break;
				}
			}
		}

    },
	
	parentFieldChange : function(component, event, helper) {
    	var controllerValue = component.find("parentField").get("v.value");// We can also use event.getSource().get("v.value")
        var pickListMap = component.get("v.childPickListMap");

        console.log("## Parent Field Change");
        console.dir(controllerValue);
        console.dir(pickListMap);
        if (controllerValue != '--- None ---') {
             //get child picklist value
            var childValues = pickListMap[controllerValue];
            var childValueList = [];
            childValueList.push('--- None ---');
            for (var i = 0; i < childValues.length; i++) {
                childValueList.push(childValues[i]);
            }
            console.log("## Child value list:")
            console.dir(childValueList);
            // set the child list
            component.set("v.childList", childValueList);
            
            if(childValues.length > 0){
                component.set("v.disabledChildField" , false);  
            }else{
                component.set("v.disabledChildField" , true); 
            }
            
        } else {
            component.set("v.childList", ['--- None ---']);
            component.set("v.disabledChildField" , true);
		}
		
		var isSelectedProjectInternal = helper.isSelectedProjectInternal(component);
		if (isSelectedProjectInternal) {
			var childList = component.get("v.childList");
			for (var i = 0; i < childList.length; i++) {
				if (childList[i] == "Internal") {
					component.set("v.childValue","9000 Internal work");
					break;
				} else if (childList[i] == "9000 Interntarbete") {
					component.set("v.childValue","9000 Interntarbete");
					break;
				}
			}	
		}

	},
	handleProjectCountrySet : function(component, event, helper) {
		console.log("## BEGIN handleProjectCountrySet");
		let country = event.getParam("Value");
		console.log("## DEFAULT COUNTRY: " + component.get("v.firstParentValue"));
		//if(component.get("v.firstParentValue") == "") {
		console.log("## Setting country.");
		component.set("v.firstParentValue", country);      
		console.log("## Calling firstParentFieldChange manually"); 
		$A.enqueueAction(component.get('c.firstParentFieldChange'));
		//} else {
		//    console.log("## PROJECT COUNTRY ALREADY SET");
		//}
		console.log("## END handleProjectCountrySet");
	},

	onChildFieldChange: function(component, event, helper) {
        console.log("## onChildFieldChange");
        let childValue = component.get("v.childValue");
        var evt = component.getEvent("activitySelectedEvt");
        evt.setParams({"activity" :  childValue});
        evt.fire();
    },
	
})