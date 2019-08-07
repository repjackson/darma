Template.add_resident.onCreated ->
    Session.set 'permission', false

Template.add_resident.events
    'keyup #last_name': (e,t)->
        first_name = $('#first_name').val()
        last_name = $('#last_name').val()
        $('#username').val("#{first_name.toLowerCase()}_#{last_name.toLowerCase()}")
        Session.set 'permission',true

    'click .create_resident': ->
        first_name = $('#first_name').val()
        last_name = $('#last_name').val()
        username = "#{first_name.toLowerCase()}_#{last_name.toLowerCase()}"
        Meteor.call 'add_user', username, (err,res)=>
            if err
                alert err
            else
                Meteor.users.update res,
                    $set:
                        first_name:first_name
                        last_name:last_name
                        added_by_username:Meteor.user().username
                        added_by_user_id:Meteor.userId()
                        roles:['resident']
                        # healthclub_checkedin:true
                Docs.insert
                    model: 'log_event'
                    object_id: res
                    body: "#{username} was created"
                # Docs.insert
                #     model:'log_event'
                #     object_id:res
                #     body: "#{username} checked in."
                new_user = Meteor.users.findOne res
                Session.set 'username_query',null
                $('.username_search').val('')
                Meteor.call 'email_verified',new_user
                Router.go "/user/#{username}/edit"


Template.add_resident.helpers
    permission: -> Session.get 'permission'
