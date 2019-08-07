if Meteor.isClient
    Template.card.helpers
        tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'
        five_tags: -> if @tags then @tags[..4]

    Template.card.events
        'click .person_tag': ->
            if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()


        'click .check_in': ->
            Meteor.users.update @_id,
                $set: checked_in: true

        'click .check_out': ->
            Meteor.users.update @_id,
                $set: checked_in: false
