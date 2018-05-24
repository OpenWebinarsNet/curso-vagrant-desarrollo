<?php
namespace AppBundle\Concern;

use Doctrine\ORM\Mapping as ORM;

trait Timestamps {

    /**
     * Set timestamps when a record is created
     * @ORM\PrePersist()
     */
    public function createdTimestamps () {
        $this->setCreatedAt(new \DateTime());
        if (property_exists($this, 'updatedAt')){
            $this->setUpdatedAt(new \DateTime());
        }
    }

    /**
     * Update timestamps when a record is updated
     * @ORM\PreUpdate()
     */
    public function updatedTimestamps () {
        if (property_exists($this, 'updatedAt')){
            $this->setUpdatedAt(new \DateTime());
        }
    }

}