@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'

# Meteor.users.helpers
#     name: ->
#         if @profile.first_name and @profile.last_name
#             "#{@profile.first_name}  #{@profile.last_name}"



Docs.before.insert (userId, doc)->
    doc._author_id = Meteor.userId()
    timestamp = Date.now()
    doc._timestamp = timestamp
    doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')

    hour = moment(timestamp).format('h')
    minute = moment(timestamp).format('m')
    ap = moment(timestamp).format('a')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    date_array = [ap, weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
    # date_array = _.each(date_array, (el)-> console.log(typeof el))
    # console.log date_array
        doc._timestamp_tags = date_array

    doc._author_id = Meteor.userId()
    if Meteor.user()
        doc._author_username = Meteor.user().username

    # doc.points = 0
    # doc.downvoters = []
    # doc.upvoters = []
    return

if Meteor.isClient
    # console.log $
    $.cloudinary.config
        cloud_name:"facet"

if Meteor.isServer
    Cloudinary.config
        cloud_name: 'facet'
        api_key: Meteor.settings.cloudinary_key
        api_secret: Meteor.settings.cloudinary_secret




# Docs.after.insert (userId, doc)->
#     console.log doc.tags
#     return

# Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
#     doc.tag_count = doc.tags?.length
#     # Meteor.call 'generate_authored_cloud'
# ), fetchPrevious: true


Docs.helpers
    author: -> Meteor.users.findOne @_author_id
    when: -> moment(@_timestamp).fromNow()
    upvoters: ->
        if @upvoter_ids
            upvoters = []
            for upvoter_id in @upvoter_ids
                upvoter = Meteor.users.findOne upvoter_id
                upvoters.push upvoter
            upvoters
    downvoters: ->
        if @downvoter_ids
            downvoters = []
            for downvoter_id in @downvoter_ids
                downvoter = Meteor.users.findOne downvoter_id
                downvoters.push downvoter
            downvoters
Meteor.users.helpers
    email_address: -> if @emails then @emails[0].address
    email_verified: -> if @emails and @emails[0] then @emails[0].verified
    five_tags: -> if @tags then @tags[..4]
    three_tags: -> if @tags then @tags[..2]
    last_name_initial: -> if @last_name then @last_name.charAt 0

Meteor.methods
    add_facet_filter: (delta_id, key, filter)->
        if key is '_keys'
            new_facet_ob = {
                key:filter
                filters:[]
                res:[]
            }
            Docs.update { _id:delta_id },
                $addToSet: facets: new_facet_ob
        Docs.update { _id:delta_id, "facets.key":key},
            $addToSet: "facets.$.filters": filter

        Meteor.call 'fum', delta_id, (err,res)->

    add_alpha_facet_filter: (alpha_id, key, filter)->
        if key is '_keys'
            new_facet_ob = {
                key:filter
                filters:[]
                res:[]
            }
            Docs.update { _id:alpha_id },
                $addToSet: facets: new_facet_ob
        Docs.update { _id:alpha_id, "facets.key":key},
            $addToSet: "facets.$.filters": filter

        Meteor.call 'fa', alpha_id, (err,res)->


    remove_facet_filter: (delta_id, key, filter)->
        if key is '_keys'
            Docs.update { _id:delta_id },
                $pull:facets: {key:filter}
        Docs.update { _id:delta_id, "facets.key":key},
            $pull: "facets.$.filters": filter
        Meteor.call 'fum', delta_id, (err,res)->


    remove_alpha_facet_filter: (alpha_id, key, filter)->
        if key is '_keys'
            Docs.update { _id:alpha_id },
                $pull:facets: {key:filter}
        Docs.update { _id:alpha_id, "facets.key":key},
            $pull: "facets.$.filters": filter
        Meteor.call 'fa', alpha_id, (err,res)->


if Meteor.isClient
    Template.docs.onCreated ->
        @autorun -> Meteor.subscribe('docs', selected_tags.array())

    Template.docs.helpers
        docs: ->
            Docs.find { },
                sort:
                    tag_count: 1
                limit: 1

        tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'

        selected_tags: -> selected_tags.array()


    Template.view.helpers
        tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'
        when: -> moment(@_timestamp).fromNow()

    Template.view.events
        'click .tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())

        'click .edit': -> Router.go("/edit/#{@_id}")

    Template.docs.events
        'click #add': ->
            Meteor.call 'add', (err,id)->
                Router.go "/edit/#{id}"

        'keyup #quick_add': (e,t)->
            e.preventDefault
            tag = $('#quick_add').val().toLowerCase()
            if e.which is 13
                if tag.length > 0
                    split_tags = tag.match(/\S+/g)
                    $('#quick_add').val('')
                    Meteor.call 'add', split_tags
                    selected_tags.clear()
                    for tag in split_tags
                        selected_tags.push tag



if Meteor.isServer
    Docs.allow
        insert: (userId, doc) -> doc._author_id is userId
        update: (userId, doc) -> userId
        # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
        remove: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles

    Meteor.publish 'docs', (selected_tags, filter)->
        # user = Meteor.users.findOne @userId
        console.log selected_tags
        console.log filter
        self = @
        match = {}
        # if filter is 'shop'
        #     match.active = true
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        if filter then match.model = filter

        Docs.find match, sort:_timestamp:-1


    Meteor.publish 'doc', (id)->
        doc = Docs.findOne id
        user = Meteor.users.findOne id
        if doc
            Docs.find id
        else if user
            Meteor.users.find id
