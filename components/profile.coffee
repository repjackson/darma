if Meteor.isClient
    Template.user_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_referenced_docs', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_models', Router.current().params.username

    Template.user_layout.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'staff_resident_widget'

    Template.user_about.helpers
        staff_resident_widgets: ->
            Docs.find
                model:'staff_resident_widget'


    Template.user_layout.helpers
        user: ->
            Meteor.users.findOne username:Router.current().params.username

        user_models: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'model'
                _id:$in:user.model_ids


    Template.user_layout.events
        'click .set_delta_model': ->
            Meteor.call 'set_delta_facets', @slug, null, true

        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            Meteor.logout()
            Router.go '/login'



    Template.user_array_element_toggle.helpers
        user_array_element_toggle_class: ->
            # user = Meteor.users.findOne Router.current().params.username
            if @user["#{@key}"] and @value in @user["#{@key}"] then 'black' else 'basic'
    Template.user_array_element_toggle.events
        'click .toggle_element': (e,t)->
            # user = Meteor.users.findOne Router.current().params.username
            if @user["#{@key}"]
                if @value in @user["#{@key}"]
                    Meteor.users.update @user._id,
                        $pull: "#{@key}":@value
                else
                    Meteor.users.update @user._id,
                        $addToSet: "#{@key}":@value
            else
                Meteor.users.update @user._id,
                    $addToSet: "#{@key}":@value


    Template.user_array_list.helpers
        users: ->
            users = []
            if @user["#{@array}"]
                for user_id in @user["#{@array}"]
                    user = Meteor.users.findOne user_id
                    users.push user
                users



    Template.user_array_list.onCreated ->
        @autorun => Meteor.subscribe 'user_array_list', @data.user, @data.array
    Template.user_array_list.helpers
        users: ->
            users = []
            if @user["#{@array}"]
                for user_id in @user["#{@array}"]
                    user = Meteor.users.findOne user_id
                    users.push user
                users




    Template.user_log.onCreated ->
        @autorun => Meteor.subscribe 'user_log', Router.current().params.username
    Template.user_log.helpers
        user_log_events: ->
            Docs.find {
                model:'log_event'
            }, sort:_timestamp:-1




if Meteor.isServer
    Meteor.publish 'user_bookmarks', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            bookmark_ids:$in:[user._id]

    Meteor.publish 'user_confirmed_transactions', (username)->
        Docs.find
            model:'karma_transaction'
            recipient:username
            # confirmed:true



    Meteor.publish 'user_log', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'log_event'
            object_id:user._id


    Meteor.publish 'user_referenced_docs', (username)->
        Docs.find
            resident:username
