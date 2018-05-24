<?php
namespace AppBundle\DataFixtures\ORM;

use AppBundle\Entity\Category;
use Doctrine\Common\DataFixtures\FixtureInterface;
use Doctrine\Common\Persistence\ObjectManager;

class LoadCategoryData implements FixtureInterface
{

    public function load(ObjectManager $manager)
    {

        $category = new Category();
        $category->setName('Test category 1');
        $category->setslug('category-1');
        $category->setPostCount(0);
        $manager->persist($category);

        $category = new Category();
        $category->setName('Test category 2');
        $category->setslug('category-2');
        $category->setPostCount(0);
        $manager->persist($category);

        $category = new Category();
        $category->setName('Test category 3');
        $category->setslug('category-3');
        $category->setPostCount(0);
        $manager->persist($category);

        $manager->flush();
    }
}