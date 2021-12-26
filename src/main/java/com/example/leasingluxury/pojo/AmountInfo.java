package com.example.leasingluxury.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AmountInfo {
    private String manufacturer;
    private String bagName;
    private double amount;
}
