public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    private List<Opportunity> newOpp;
    private List<Opportunity> oldOpp;
    private Map<Id, Opportunity> newOppMap;
    private Map<Id, Opportunity> oldOppMap;

    OpportunityHelper oppHelper = new OpportunityHelper();

    public OpportunityTriggerHandler() {
        this.oldOpp = (List<Opportunity>) Trigger.old;
        this.newOpp = (List<Opportunity>) Trigger.new;
        this.newOppMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.oldOppMap = (Map<Id, Opportunity>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        oppHelper.setType(newOpp);
    }

    public override void beforeDelete() {
        oppHelper.validateCloseOpportunity(oldOpp);
    }

    public override void afterInsert() {
        oppHelper.insertTask(newOpp);        
    }

    public override void beforeUpdate() {
        oppHelper.updateDescriptionFromStage(newOpp, oldOppMap);
        oppHelper.amountValidation(newOpp);
    }

    public override void afterDelete() {
        oppHelper.notifyOwnersOpportunityDeleted(oldOpp);
    }

    public override void afterUndelete() {
        oppHelper.assignPrimaryContact(newOppMap);
    }
}