/**
 * @name orderTrigger
 * @description
**/
trigger orderTrigger on Order (after update) {
    
    OrderTriggerHelper.afterUpdate(Trigger.newMap, Trigger.oldMap);
}