DECENT FEATURES
```
expose(:company)
expose(:people, ancestor: :company)
expose(:person)

expose(:company, model: :enterprisey_company)
expose(:company, params: :company_params)
expose(:article, finder: :find_by_slug)
expose(:article, finder_parameter: :slug)

expose(:articles) {|default| default.limit(10) }

expose(:post, strategy: VerifiableStrategy)

```

ADEQUATE FEATURES
```
expose :thing, fetch: ->{ get_thing_some_way_or_another }
expose :thing, id: ->{ params[:thing_id] || params[:id] }
expose :thing, find: ->(id, scope){ scope.find(id) }
expose :thing, build: ->(thing_params, scope){ scope.new(thing_params) }
expose :thing, build_params: ->{ strong_params }
expose :user, scope: ->{ User.active }
expose :thing, model: ->{ AnotherThing }
expose :thing, decorate: ->(thing){ ThingDecorator.new(thing) }
exposure_config :cool_find, find: ->{ very_cool_find_code }
```
