<?php

namespace App\Tests\Controller;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Symfony\Component\BrowserKit\Client;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * @group functional
 */
final class ContactControllerFunctionalTest extends WebTestCase
{
    /**
     * @var Client
     */
    private $client;

    /**
     * {@inheritdoc}
     */
    protected function setUp()
    {
        $this->client = static::createClient();
    }
    
    public function testContactFormSubmission(): void
    {
        $this->client->followRedirects();

        $crawler = $this->client->request(
            Request::METHOD_GET,
            '/contact'
        );

        static::assertSame(
            Response::HTTP_OK,
            $this->client->getResponse()->getStatusCode()
        );

        $form = $crawler->selectButton('Submit')->form();

        $form['contact[subject]'] = 'Some new subject';
        $form['contact[email]'] = 'test@test.test';
        $form['contact[content]'] = 'Some new content !';

        $crawler = $this->client->submit($form);

        static::assertSame(
            Response::HTTP_OK,
            $this->client->getResponse()->getStatusCode()
        );
        static::assertSame(
            1,
            $crawler->filter('html:contains("The email has been handled")')->count(),
            'The flash message should be visible'
        );
    }
}
