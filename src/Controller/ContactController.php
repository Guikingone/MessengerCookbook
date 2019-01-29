<?php

namespace App\Controller;

use App\Form\Type\ContactType;
use App\Messenger\Message\ContactEmailMessage;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\Form\FormFactoryInterface;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Session\SessionInterface;
use Symfony\Component\Messenger\MessageBusInterface;
use Symfony\Component\Routing\Annotation\Route;

class ContactController extends AbstractController
{
    private $formFactory;

    private $messageBus;

    public function __construct(
        FormFactoryInterface $formFactory,
        MessageBusInterface $messageBus
    ) {
        $this->formFactory = $formFactory;
        $this->messageBus = $messageBus;
    }

    /**
     * @Route(
     *     name="contact",
     *     path="/contact",
     *     methods={"GET", "POST"}
     * )
     */
    public function contact(Request $request): Response
    {
        $type = $this->formFactory->create(ContactType::class)
                                  ->handleRequest($request);

        if ($type->isSubmitted() && $type->isValid()) {

            $data = $type->getData();

            $this->messageBus->dispatch(new ContactEmailMessage($data));

            $this->get('session')
                 ->getFlashBag()
                 ->add('success', 'The email has been handled')
            ;

            return $this->redirectToRoute('contact');
        }

        return $this->render('contact/contact.html.twig', [
            'form' => $type->createView(),
        ]);
    }
}
