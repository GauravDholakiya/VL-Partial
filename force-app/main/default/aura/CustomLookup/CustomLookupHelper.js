/**
 * @author Jozef 
 * @date 28.1.2019.
 * @description //TODO
 */
({

    setName: function(component, recordId){
        var action = component.get("c.fetchLookUpValuesById");
        action.setParams({
            'recordId': recordId,
            'ObjectName' : component.get("v.objectAPIName")
        });

        action.setCallback(this, function(response) {
          //$A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                //console.log(storeResponse);
                component.set("v.SearchKeyWord", storeResponse.Name);
            }

        });
      // enqueue the Action
        $A.enqueueAction(action);
    },

	searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method
     var action = component.get("c.fetchLookUpValues");
      // set param to method
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName")
          });
      // set a callBack
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }

        });
      // enqueue the Action
        $A.enqueueAction(action);

	},

	setCompPosition : function(cmp, event){
	    var withFixedPosition = cmp.get('v.withFixedPosition');
	    if (withFixedPosition == true){
            console.log('setCompPosition');
            var element = cmp.find("lookupField").getElement();
            var docElement = element.getBoundingClientRect();

            if (!$A.util.isEmpty(docElement)){
                var positionX =  element.getBoundingClientRect().left;
                var positionConstX = cmp.get('v.posConstX');
                var left = positionX + positionConstX;
                var positionY =  element.getBoundingClientRect().top;
                var positionConstY = cmp.get('v.posConstY');
                var top = positionY + positionConstY;
                //console.log('------------>');
                //console.log(positionY);
                //console.log('<------------');

                //console.log(left);
                cmp.set('v.listboxPos', 'left: ' + left + 'px; position:fixed !important; top: ' +  top + 'px;');
                //cmp.set('v.listboxPosY', positionY);
            }
        }

        //console.log('---------->')
                //console.log(element);
                //console.log(element.childNodes);
                //console.log(element.offsetLeft);
                //console.log(element.offsetParent);
                //console.log(element.offsetWidth);
                //console.log(element.scrollLeft)

        //console.log(element.getBoundingClientRect().left);
        //console.log('<----------');

    },
})