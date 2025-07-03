<?php

namespace App\Http\Controllers;

use Illuminate\Http\Resources\Json\JsonResource;

abstract class WebController
{
    public function __construct()
    {
        // enables resource wrapping without data key
        JsonResource::withoutWrapping();
    }
}
