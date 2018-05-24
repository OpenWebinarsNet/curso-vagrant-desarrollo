<?php
namespace AppBundle\EventListener;


use AppBundle\Entity\Post;
use Doctrine\Common\EventSubscriber;
use Doctrine\ORM\Event\PreUpdateEventArgs;
use Doctrine\ORM\Event\LifecycleEventArgs;

class CounterSubscriber implements EventSubscriber
{

    /**
     * Returns an array of events this subscriber wants to listen to.
     *
     * @return array
     */
    public function getSubscribedEvents()
    {
        return [
            'preUpdate',
            'postPersist',
            'postRemove'
        ];
    }

    public function preUpdate(PreUpdateEventArgs $event) {
        if ($event->getObject() instanceof Post) {
            if ($event->hasChangedField('category')) {
                $event
                    ->getEntityManager()
                    ->getRepository("AppBundle:Category")
                    ->decrementCount($event->getOldValue('category'))
                    ->incrementCount($event->getNewValue('category'));
            }
        }
    }

    public function postRemove(LifecycleEventArgs $event) {
        if ($event->getObject() instanceof Post) {
            $event
                ->getEntityManager()
                ->getRepository("AppBundle:Category")
                ->decrementCount($event->getEntity()->getCategory());
        }
    }

    public function postPersist(LifecycleEventArgs $event) {
        if ($event->getObject() instanceof Post) {
            $event
                ->getEntityManager()
                ->getRepository("AppBundle:Category")
                ->incrementCount($event->getEntity()->getCategory());
        }

    }

}