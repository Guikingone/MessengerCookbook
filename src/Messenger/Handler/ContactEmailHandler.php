<?php

namespace App\Messenger\Handler;

use App\Messenger\Message\ContactEmailMessage;
use Symfony\Component\Messenger\Handler\MessageHandlerInterface;
use Twig\Environment;

final class ContactEmailHandler implements MessageHandlerInterface
{
    private $mailer;

    private $twig;

    public function __construct(
        \Swift_Mailer $mailer,
        Environment $twig
    ) {
        $this->mailer = $mailer;
        $this->twig = $twig;
    }

    public function __invoke(ContactEmailMessage $message): void
    {
        $payload = $message->getPayload();

        $mail = (new \Swift_Message)
                ->setFrom($payload->email)
                ->setBody($this->twig->render('emails/contact.html.twig', [
                    'payload' => $payload,
                ]), 'text/html')
                ->setSubject('New message !')
        ;

        $this->mailer->send($mail);
    }
}
