BlogMVC : Symfony 3
========================

[![Build Status](https://travis-ci.org/Grafikart/BlogMVC-Symfony3.svg?branch=master)](https://travis-ci.org/Grafikart/BlogMVC-Symfony3)

This is my contribution to BlogMVC.com using Symfony 3. I used this project to learn the framework so if you think some patterns are not respected please create an issue :). 

```bash
composer install
php bin/console doctrine:schema:update --force
# php bin/console doctrine:migrations:migrate
php bin/console doctrine:fixtures:load
php bin/console server:run
```

Bundle
---------

I cheated a bit using 2 bundles :

- KnpPaginatorBundle for the pagination
- KnpTimeBundle for the "3 minutes ago" text

We could cheat even more using 

- [FOSUserBundle](https://github.com/FriendsOfSymfony/FOSUserBundle) to manage user login / registration
- [SonataAdminBundle](https://github.com/sonata-project/SonataAdminBundle) to manage backend
- [StofDoctrineExtensionsBundle](https://github.com/stof/StofDoctrineExtensionsBundle) to manage the "sluggable" behaviour

Questions 
----------

Here are some question discovered during this project

- To "counter cache" the number of posts associated to each Category I created an [EventSubscriber](https://github.com/Grafikart/BlogMVC-Symfony3/blob/master/src/AppBundle/EventListener/CounterSubscriber.php) but I have to check the entity type.
Is there a way to attach a subscriber to an Entity using annotation or anything else ?
- To avoid n+1 queries on a ManyToOne I have to give up the findAll / findBy methods and use the queryBuilder to make a LEFT JOIN. Is there a better way ? Does it affect Doctrine hydratation ?
- I split my backend in a bundle instead of namespace. is it considered a good or bad practice ? Is there a way to prefix all routes inside a Bundle ?
- The sidebar need to be shared accress pages. I created a service injected as a "global" twig variable [PartialService](https://github.com/Grafikart/BlogMVC-Symfony3/blob/master/src/AppBundle/Twig/Partials.php). Is there a better way to achieve that ?
- For the timestamps (created_at and updated_at) I used a trait since it seemed to be the easies way to reach the goal. Is it considered bad 
