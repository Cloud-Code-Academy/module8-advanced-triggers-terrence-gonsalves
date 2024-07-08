/*
OpportunityHelper Overview

The `OpportunityHelper` class is designed to provide helper methods that assist in performing specific operations on Opportunities records. 
This class is intended to modularize the logic used in any Opportunity Triggers to ensure separation of concerns, improve readability, 
and ease maintenance. 

Methods:
- assignPrimaryContact(Map<Id,Opportunity> oppNewMap): 
    - Purpose: Assigns a primary contact with the title of 'VP Sales' to undeleted Opportunities. Only updates the Opportunities that don't 
      already have a primary contact

- notifyOwnersOpportunityDeleted(List<Opportunity> opps): 
    - Purpose: Sends an email notification to the owner of the Opportunity when it gets deleted. Uses Salesforce's Messaging.SingleEmailMessage 
      to send the email.lt contact related to the Account after the Account is inserted. You'll need to define the method's signature 
      and implement its logic.

- updateDescriptionFromStage(List<Opportunity> newOpps, Map<Id, Opportunity oldOppMap):
    - Purpose: Updates the description on the StageName of an Opportunity if the StageName is not null

- insertTask(List<Opportunity> newOpps):
    - Purpose: Inserts a new Task record related to the Opportunity. 

- setType(List<Opportunity> newOpp):
    - Purpose: Validates that the Type field is not empty and if it is set the Type to 'New Customer'.

- validateCloseOpportunity(List<Opportunity> oldOpp):
*/
public with sharing class OpportunityHelper { 
    public class CustomOppException extends Exception {}

    public void setType(List<Opportunity> newOpp) {   
        Opportunity opp = newOpp[0];

        if (opp.Type == null) {
            opp.Type = 'New Customer';
        }
    }

    public void amountValidation(List<Opportunity> newOpp) {
        for(Opportunity opp : newOpp){
            if(opp.Amount < 5000){
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }
    }

    public void validateCloseOpportunity(List<Opportunity> oldOpp) {
        for (Opportunity oppOld : oldOpp) {
            if (oppOld.IsClosed) {
                oppOld.addError('Cannot delete closed opportunity');
            }
        }
    }

    public void insertTask(List<Opportunity> newOpps) {
        List<Task> newTasks = new List<Task>(); 

        for (Opportunity opp : newOpps) {
            Task tsk = new Task();

            tsk.Subject = 'Call Primary Contact';
            tsk.WhatId = opp.Id;
            tsk.WhoId = opp.Primary_Contact__c;
            tsk.OwnerId = opp.OwnerId;
            tsk.ActivityDate = Date.today().addDays(3);

            newTasks.add(tsk);
        }

        try {
            if (!newTasks.isEmpty()) {
                insert newTasks;
            } else {
                throw new CustomOppException('No new tasks to insert!');
            }
        } catch (DmlException e) {
            System.debug('There has been error with the insert operation: ' + e.getMessage());
        }
    }

    public void updateDescriptionFromStage(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap) {
        for (Opportunity opp : newOpps) {
            if (opp.StageName != null && opp.StageName != oldOppMap.get(opp.Id).StageName) { 
                opp.Description += '\n Stage Change:' + opp.StageName + ':' + DateTime.now().format();
            }           
        }

        try {
            update newOpps;
        } catch (DmlException e) {
            System.debug('There has been error with the update operation: ' + e.getMessage());
        }
    }

    public void assignPrimaryContact(Map<Id,Opportunity> oppNewMap) {        
        List<Opportunity> updatedOpp = new List<Opportunity>();
        Set<Id> accIds = new Set<Id>();

        for (Opportunity o : oppNewMap.values()) {
            accIds.add(o.AccountId);
        }
        
        //if (Contact.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.Contact.fields.AccountId.isAccessible() &&
            //Schema.SObjectType.Contact.fields.Id.isAccessible()) {
            Contact[] primaryContact = [SELECT Id, AccountId FROM Contact WHERE Title = 'VP Sales' AND AccountId in :accIds];
            
            for (Opportunity opp : oppNewMap.values()) {
                if (opp.Primary_Contact__c == null) {
                    Opportunity oppToUpdate = new Opportunity(Id = opp.Id);

                    if (primaryContact.size() > 0) {
                        oppToUpdate.Primary_Contact__c = primaryContact[0].Id;
                        updatedOpp.add(oppToUpdate);
                    }
                }
            }

            Database.update(updatedOpp);
        //}   
    }
    
    public void notifyOwnersOpportunityDeleted(List<Opportunity> opps) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> toAddresses = new List<String>();
        Set<Id> ownerIds = new Set<Id>();

        for (Opportunity opp : opps) {
            ownerIds.add(opp.OwnerId);
        }
            
        User[] userEmails = [SELECT Id, Email FROM User WHERE Id in :ownerIds];
        
        for (Opportunity opp : opps) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            // add all the emails
            for (User u : userEmails) {
                if (opp.OwnerId == u.Id) {
                    toAddresses.add(u.Email);
                }
            }

            mail.setToAddresses(toAddresses);
            mail.setSubject('Opportunity Deleted : ' + opp.Name);
            mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
            mails.add(mail);
        }        
        
        try {
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    }
}