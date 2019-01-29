<?php

namespace App\Messenger\Message;

use App\Domain\DTO\ContactDTO;

class ContactEmailMessage
{
    private $payload;

    public function __construct(ContactDTO $payload)
    {
        $this->payload = $payload;
    }

    public function getPayload(): ContactDTO
    {
        return $this->payload;
    }
}
