<?php

use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::get('/', \App\Http\Controllers\Web\IndexController::class)
    ->name('index');
