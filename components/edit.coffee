if Meteor.isClient
    Template.edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_from_child_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_fields_from_child_id', Router.current().params.doc_id

    Template.edit.helpers
        current_doc: ->
            Docs.findOne Router.current().params.doc_id

        fields: ->
            Docs.find
                model:'field'

if Meteor.isServer
    Meteor.publish 'model_from_child_id', (child_id)->
        child = Docs.findOne child_id
        Docs.find
            model:'model'
            slug:child.type


    Meteor.publish 'model_fields_from_child_id', (child_id)->
        child = Docs.findOne child_id
        model = Docs.findOne
            model:'model'
            slug:child.type
        Docs.find
            model:'field'
            parent_id:model._id
